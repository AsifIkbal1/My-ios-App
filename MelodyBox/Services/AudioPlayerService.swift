import Foundation
import AVFoundation
import MediaPlayer
import Observation
import UIKit
import SwiftUI

public enum PlaybackState: Equatable {
    case idle
    case loading
    case playing
    case paused
    case failed(String)
    
    public var isPlaying: Bool {
        if case .playing = self { return true }
        return false
    }
}

public enum RepeatMode: String, CaseIterable {
    case off = "off"
    case all = "all"
    case one = "one"
    
    public var iconName: String {
        switch self {
        case .off: return "repeat"
        case .all: return "repeat"
        case .one: return "repeat.1"
        }
    }
}

@Observable
public final class AudioPlayerService: NSObject, NowPlayingCommandDelegate {
    public static let shared = AudioPlayerService()
    
    // Playback State
    public var currentTrack: Track?
    public var playbackState: PlaybackState = .idle
    public var currentTime: TimeInterval = 0
    public var duration: TimeInterval = 0
    public var isSeeking: Bool = false
    public var isShuffled: Bool = false
    public var repeatMode: RepeatMode = .off
    
    // Queue State
    public var queue: [Track] = []
    public var originalQueue: [Track] = []
    public var currentIndex: Int = -1
    
    // Internal AVPlayer
    private var player: AVPlayer?
    private var timeObserverToken: Any?
    private var playerItemStatusObserver: NSKeyValueObservation?
    private var wasInterruptedPlaying = false
    
    // State restoration keys
    private let lastTrackIdKey = "MelodyBox.LastTrackId"
    private let lastTimeKey = "MelodyBox.LastPlaybackTime"
    
    public override init() {
        super.init()
        setupAudioSession()
        setupNotifications()
        NowPlayingManager.shared.setupRemoteCommands(delegate: self)
    }
    
    deinit {
        removeTimeObserver()
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Audio Session Setup
    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, policy: .longFormAudio)
            try session.setActive(true)
        } catch {
            print("Failed to configure AVAudioSession: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Notifications Setup
    private func setupNotifications() {
        // Interruption (Phone calls, alarms)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAudioInterruption(_:)),
            name: AVAudioSession.interruptionNotification,
            object: AVAudioSession.sharedInstance()
        )
        
        // Route Change (Headphones unplugged / Bluetooth disconnected)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAudioRouteChange(_:)),
            name: AVAudioSession.routeChangeNotification,
            object: AVAudioSession.sharedInstance()
        )
    }
    
    @objc private func handleAudioInterruption(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }
        
        switch type {
        case .began:
            wasInterruptedPlaying = playbackState.isPlaying
            if wasInterruptedPlaying {
                pause()
            }
        case .ended:
            guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
            if options.contains(.shouldResume) && wasInterruptedPlaying {
                play()
            }
            wasInterruptedPlaying = false
        @unknown default:
            break
        }
    }
    
    @objc private func handleAudioRouteChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
              let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else {
            return
        }
        
        // When headphones are unplugged or Bluetooth disconnects, pause gracefully
        if reason == .oldDeviceUnavailable {
            if playbackState.isPlaying {
                pause()
            }
        }
    }
    
    // MARK: - Playback Control
    
    /// Starts playing a track from a provided list or standalone
    public func play(track: Track, from list: [Track]? = nil) {
        if let list = list, !list.isEmpty {
            self.originalQueue = list
            if isShuffled {
                var shuffled = list
                if let idx = shuffled.firstIndex(where: { $0.id == track.id }) {
                    shuffled.remove(at: idx)
                    shuffled.shuffle()
                    shuffled.insert(track, at: 0)
                }
                self.queue = shuffled
                self.currentIndex = 0
            } else {
                self.queue = list
                self.currentIndex = list.firstIndex(where: { $0.id == track.id }) ?? 0
            }
        } else {
            if !queue.contains(where: { $0.id == track.id }) {
                queue.append(track)
                originalQueue.append(track)
            }
            self.currentIndex = queue.firstIndex(where: { $0.id == track.id }) ?? 0
        }
        
        loadAndPlay(track: track)
    }
    
    private func loadAndPlay(track: Track, startTime: TimeInterval = 0) {
        self.currentTrack = track
        self.playbackState = .loading
        self.currentTime = startTime
        self.duration = track.duration
        
        guard let playbackURL = track.playbackURL else {
            self.playbackState = .failed("No playable URL or local file found for this track.")
            return
        }
        
        // Remove previous observers
        removeTimeObserver()
        playerItemStatusObserver?.invalidate()
        NotificationCenter.default.removeObserver(
            self,
            name: .AVPlayerItemDidPlayToEndTime,
            object: nil
        )
        
        let playerItem = AVPlayerItem(url: playbackURL)
        
        // Observe item readiness
        playerItemStatusObserver = playerItem.observe(\.status, options: [.new, .old]) { [weak self] item, _ in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch item.status {
                case .readyToPlay:
                    let itemDuration = item.duration.seconds
                    if !itemDuration.isNaN && itemDuration > 0 {
                        self.duration = itemDuration
                        track.duration = itemDuration
                    }
                    if startTime > 0 {
                        self.seek(to: startTime)
                    }
                    self.player?.play()
                    self.playbackState = .playing
                    self.updateNowPlayingInfo()
                case .failed:
                    let msg = item.error?.localizedDescription ?? "Playback failed."
                    self.playbackState = .failed(msg)
                case .unknown:
                    break
                @unknown default:
                    break
                }
            }
        }
        
        // Observer for track completion
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerItemDidReachEnd(_:)),
            name: .AVPlayerItemDidPlayToEndTime,
            object: playerItem
        )
        
        if self.player == nil {
            self.player = AVPlayer(playerItem: playerItem)
        } else {
            self.player?.replaceCurrentItem(with: playerItem)
        }
        
        setupTimeObserver()
        
        // Increment play count & mark last played
        track.playCount += 1
        track.lastPlayedDate = Date()
        savePlaybackState()
    }
    
    public func play() {
        guard let player = player else {
            if let current = currentTrack {
                loadAndPlay(track: current)
            }
            return
        }
        player.play()
        playbackState = .playing
        updateNowPlayingInfo()
    }
    
    public func pause() {
        player?.pause()
        playbackState = .paused
        savePlaybackState()
        updateNowPlayingInfo()
    }
    
    public func togglePlayPause() {
        if playbackState.isPlaying {
            pause()
        } else {
            play()
        }
    }
    
    public func nextTrack() {
        guard !queue.isEmpty else { return }
        
        if repeatMode == .one, let current = currentTrack {
            seek(to: 0)
            play()
            return
        }
        
        let nextIndex = currentIndex + 1
        if nextIndex < queue.count {
            currentIndex = nextIndex
            loadAndPlay(track: queue[currentIndex])
        } else if repeatMode == .all {
            currentIndex = 0
            loadAndPlay(track: queue[0])
        } else {
            // Queue finished
            pause()
            seek(to: 0)
        }
    }
    
    public func previousTrack() {
        guard !queue.isEmpty else { return }
        
        // If elapsed > 3 seconds, restart current track
        if currentTime > 3.0 {
            seek(to: 0)
            return
        }
        
        let prevIndex = currentIndex - 1
        if prevIndex >= 0 {
            currentIndex = prevIndex
            loadAndPlay(track: queue[currentIndex])
        } else if repeatMode == .all {
            currentIndex = queue.count - 1
            loadAndPlay(track: queue[currentIndex])
        } else {
            seek(to: 0)
        }
    }
    
    public func seek(to time: TimeInterval) {
        guard let player = player else { return }
        let clampedTime = duration > 0 ? max(0, min(time, duration)) : max(0, time)
        self.currentTime = clampedTime
        let cmTime = CMTime(seconds: clampedTime, preferredTimescale: 600)
        player.seek(to: cmTime, toleranceBefore: .zero, toleranceAfter: .zero) { [weak self] _ in
            self?.updateNowPlayingInfo()
        }
    }
    
    public func skipForward(interval: TimeInterval = 15) {
        seek(to: currentTime + interval)
    }
    
    public func skipBackward(interval: TimeInterval = 15) {
        seek(to: currentTime - interval)
    }
    
    public func toggleShuffle() {
        isShuffled.toggle()
        guard let current = currentTrack else { return }
        if isShuffled {
            var shuffled = originalQueue
            shuffled.removeAll(where: { $0.id == current.id })
            shuffled.shuffle()
            shuffled.insert(current, at: 0)
            queue = shuffled
            currentIndex = 0
        } else {
            queue = originalQueue
            currentIndex = originalQueue.firstIndex(where: { $0.id == current.id }) ?? 0
        }
    }
    
    public func cycleRepeatMode() {
        switch repeatMode {
        case .off: repeatMode = .all
        case .all: repeatMode = .one
        case .one: repeatMode = .off
        }
    }
    
    // MARK: - Queue Management
    public func addToQueue(_ track: Track) {
        queue.append(track)
        originalQueue.append(track)
    }
    
    public func playNext(_ track: Track) {
        let insertIndex = currentIndex + 1
        if insertIndex <= queue.count {
            queue.insert(track, at: insertIndex)
            originalQueue.append(track)
        } else {
            queue.append(track)
            originalQueue.append(track)
        }
    }
    
    public func removeFromQueue(at offsets: IndexSet) {
        for index in offsets {
            if index == currentIndex {
                nextTrack()
            }
        }
        queue.remove(atOffsets: offsets)
        if let current = currentTrack {
            currentIndex = queue.firstIndex(where: { $0.id == current.id }) ?? 0
        }
    }
    
    public func moveQueueItem(from source: IndexSet, to destination: Int) {
        queue.move(fromOffsets: source, toOffset: destination)
        if let current = currentTrack {
            currentIndex = queue.firstIndex(where: { $0.id == current.id }) ?? 0
        }
    }
    
    // MARK: - Private Time Observers & State Persistence
    
    private func setupTimeObserver() {
        removeTimeObserver()
        let interval = CMTime(seconds: 0.5, preferredTimescale: 600)
        timeObserverToken = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self, !self.isSeeking else { return }
            self.currentTime = time.seconds
        }
    }
    
    private func removeTimeObserver() {
        if let token = timeObserverToken {
            player?.removeTimeObserver(token)
            timeObserverToken = nil
        }
    }
    
    @objc private func playerItemDidReachEnd(_ notification: Notification) {
        DispatchQueue.main.async { [weak self] in
            self?.nextTrack()
        }
    }
    
    private func updateNowPlayingInfo() {
        guard let track = currentTrack else {
            NowPlayingManager.shared.clearNowPlaying()
            return
        }
        var image: UIImage? = nil
        if let artworkData = track.artworkData {
            image = UIImage(data: artworkData)
        }
        
        let rate: Float = playbackState.isPlaying ? 1.0 : 0.0
        NowPlayingManager.shared.updateNowPlaying(
            title: track.title,
            artist: track.artist,
            album: track.album,
            duration: duration,
            currentTime: currentTime,
            playbackRate: rate,
            artworkImage: image
        )
    }
    
    private func savePlaybackState() {
        guard let current = currentTrack else { return }
        UserDefaults.standard.set(current.id, forKey: lastTrackIdKey)
        UserDefaults.standard.set(currentTime, forKey: lastTimeKey)
    }
    
    public func restoreLastPlaybackState(from allTracks: [Track]) {
        guard let lastTrackId = UserDefaults.standard.string(forKey: lastTrackIdKey),
              let track = allTracks.first(where: { $0.id == lastTrackId }) else {
            return
        }
        let lastTime = UserDefaults.standard.double(forKey: lastTimeKey)
        self.currentTrack = track
        self.currentTime = lastTime
        self.duration = track.duration
        self.queue = [track]
        self.originalQueue = [track]
        self.currentIndex = 0
        self.playbackState = .paused
    }
    
    // MARK: - NowPlayingCommandDelegate
    public func handlePlayCommand() -> MPRemoteCommandHandlerStatus {
        play()
        return .success
    }
    
    public func handlePauseCommand() -> MPRemoteCommandHandlerStatus {
        pause()
        return .success
    }
    
    public func handleTogglePlayPauseCommand() -> MPRemoteCommandHandlerStatus {
        togglePlayPause()
        return .success
    }
    
    public func handleNextTrackCommand() -> MPRemoteCommandHandlerStatus {
        nextTrack()
        return .success
    }
    
    public func handlePreviousTrackCommand() -> MPRemoteCommandHandlerStatus {
        previousTrack()
        return .success
    }
    
    public func handleSeekCommand(to time: TimeInterval) -> MPRemoteCommandHandlerStatus {
        seek(to: time)
        return .success
    }
    
    public func handleSkipForwardCommand(interval: TimeInterval) -> MPRemoteCommandHandlerStatus {
        skipForward(interval: interval)
        return .success
    }
    
    public func handleSkipBackwardCommand(interval: TimeInterval) -> MPRemoteCommandHandlerStatus {
        skipBackward(interval: interval)
        return .success
    }
}
