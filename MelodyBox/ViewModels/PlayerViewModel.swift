import SwiftUI
import Observation

@Observable
public final class PlayerViewModel {
    public static let shared = PlayerViewModel()
    
    public var audioService: AudioPlayerService = .shared
    public var isNowPlayingExpanded: Bool = false
    public var isQueueSheetPresented: Bool = false
    public var isTrackInfoPresented: Bool = false
    
    public init() {}
    
    public var currentTrack: Track? {
        audioService.currentTrack
    }
    
    public var playbackState: PlaybackState {
        audioService.playbackState
    }
    
    public var isPlaying: Bool {
        audioService.playbackState.isPlaying
    }
    
    public var currentTime: TimeInterval {
        get { audioService.currentTime }
        set { audioService.currentTime = newValue }
    }
    
    public var duration: TimeInterval {
        audioService.duration
    }
    
    public var progress: Double {
        guard duration > 0 else { return 0 }
        return min(1.0, max(0.0, currentTime / duration))
    }
    
    public var formattedCurrentTime: String {
        currentTime.formattedDuration
    }
    
    public var formattedRemainingTime: String {
        let remaining = max(0, duration - currentTime)
        return "-\(remaining.formattedDuration)"
    }
    
    public func play(track: Track, from list: [Track]? = nil) {
        audioService.play(track: track, from: list)
    }
    
    public func togglePlayPause() {
        audioService.togglePlayPause()
    }
    
    public func nextTrack() {
        audioService.nextTrack()
    }
    
    public func previousTrack() {
        audioService.previousTrack()
    }
    
    public func seek(to progress: Double) {
        let targetTime = progress * duration
        audioService.seek(to: targetTime)
    }
    
    public func skipForward() {
        audioService.skipForward(interval: 15)
    }
    
    public func skipBackward() {
        audioService.skipBackward(interval: 15)
    }
    
    public func toggleShuffle() {
        audioService.toggleShuffle()
    }
    
    public func cycleRepeatMode() {
        audioService.cycleRepeatMode()
    }
}
