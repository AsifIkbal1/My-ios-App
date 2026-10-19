import Foundation
import MediaPlayer
import UIKit

public protocol NowPlayingCommandDelegate: AnyObject {
    func handlePlayCommand() -> MPRemoteCommandHandlerStatus
    func handlePauseCommand() -> MPRemoteCommandHandlerStatus
    func handleTogglePlayPauseCommand() -> MPRemoteCommandHandlerStatus
    func handleNextTrackCommand() -> MPRemoteCommandHandlerStatus
    func handlePreviousTrackCommand() -> MPRemoteCommandHandlerStatus
    func handleSeekCommand(to time: TimeInterval) -> MPRemoteCommandHandlerStatus
    func handleSkipForwardCommand(interval: TimeInterval) -> MPRemoteCommandHandlerStatus
    func handleSkipBackwardCommand(interval: TimeInterval) -> MPRemoteCommandHandlerStatus
}

public final class NowPlayingManager {
    public static let shared = NowPlayingManager()
    
    public weak var delegate: NowPlayingCommandDelegate?
    private var isCommandCenterConfigured = false
    
    private init() {}
    
    public func setupRemoteCommands(delegate: NowPlayingCommandDelegate) {
        self.delegate = delegate
        guard !isCommandCenterConfigured else { return }
        isCommandCenterConfigured = true
        
        let commandCenter = MPRemoteCommandCenter.shared()
        
        // Play / Pause
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget { [weak self] _ in
            self?.delegate?.handlePlayCommand() ?? .commandFailed
        }
        
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            self?.delegate?.handlePauseCommand() ?? .commandFailed
        }
        
        commandCenter.togglePlayPauseCommand.isEnabled = true
        commandCenter.togglePlayPauseCommand.addTarget { [weak self] _ in
            self?.delegate?.handleTogglePlayPauseCommand() ?? .commandFailed
        }
        
        // Next / Previous
        commandCenter.nextTrackCommand.isEnabled = true
        commandCenter.nextTrackCommand.addTarget { [weak self] _ in
            self?.delegate?.handleNextTrackCommand() ?? .commandFailed
        }
        
        commandCenter.previousTrackCommand.isEnabled = true
        commandCenter.previousTrackCommand.addTarget { [weak self] _ in
            self?.delegate?.handlePreviousTrackCommand() ?? .commandFailed
        }
        
        // Seeking
        commandCenter.changePlaybackPositionCommand.isEnabled = true
        commandCenter.changePlaybackPositionCommand.addTarget { [weak self] event in
            guard let event = event as? MPChangePlaybackPositionCommandEvent else {
                return .commandFailed
            }
            return self?.delegate?.handleSeekCommand(to: event.positionTime) ?? .commandFailed
        }
        
        // Skip 15s forward & backward
        commandCenter.skipForwardCommand.isEnabled = true
        commandCenter.skipForwardCommand.preferredIntervals = [15]
        commandCenter.skipForwardCommand.addTarget { [weak self] _ in
            self?.delegate?.handleSkipForwardCommand(interval: 15) ?? .commandFailed
        }
        
        commandCenter.skipBackwardCommand.isEnabled = true
        commandCenter.skipBackwardCommand.preferredIntervals = [15]
        commandCenter.skipBackwardCommand.addTarget { [weak self] _ in
            self?.delegate?.handleSkipBackwardCommand(interval: 15) ?? .commandFailed
        }
    }
    
    public func updateNowPlaying(
        title: String,
        artist: String,
        album: String,
        duration: TimeInterval,
        currentTime: TimeInterval,
        playbackRate: Float,
        artworkImage: UIImage? = nil
    ) {
        var info = [String: Any]()
        info[MPMediaItemPropertyTitle] = title
        info[MPMediaItemPropertyArtist] = artist
        info[MPMediaItemPropertyAlbumTitle] = album
        info[MPMediaItemPropertyPlaybackDuration] = max(0, duration)
        info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = max(0, currentTime)
        info[MPNowPlayingInfoPropertyPlaybackRate] = playbackRate
        info[MPNowPlayingInfoPropertyDefaultPlaybackRate] = 1.0
        
        if let image = artworkImage {
            let artwork = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
            info[MPMediaItemPropertyArtwork] = artwork
        } else {
            // Generate standard branded artwork for lockscreen if none provided
            let defaultImage = createBrandArtwork(title: title, artist: artist)
            let artwork = MPMediaItemArtwork(boundsSize: CGSize(width: 600, height: 600)) { _ in defaultImage }
            info[MPMediaItemPropertyArtwork] = artwork
        }
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }
    
    public func clearNowPlaying() {
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }
    
    private func createBrandArtwork(title: String, artist: String) -> UIImage {
        let size = CGSize(width: 600, height: 600)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            // Dark purple gradient background
            let colors = [
                UIColor(red: 0.14, green: 0.08, blue: 0.24, alpha: 1.0).cgColor,
                UIColor(red: 0.03, green: 0.03, blue: 0.05, alpha: 1.0).cgColor
            ]
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors as CFArray, locations: [0.0, 1.0])!
            ctx.cgContext.drawLinearGradient(gradient, start: CGPoint.zero, end: CGPoint(x: size.width, y: size.height), options: [])
            
            // Draw glowing icon/initials
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            let symbolConfig = UIImage.SymbolConfiguration(pointSize: 120, weight: .bold)
            if let noteImage = UIImage(systemName: "music.note", withConfiguration: symbolConfig)?.withTintColor(UIColor(red: 0.66, green: 0.33, blue: 0.97, alpha: 1.0), renderingMode: .alwaysOriginal) {
                let noteRect = CGRect(x: (size.width - 120) / 2, y: 160, width: 120, height: 120)
                noteImage.draw(in: noteRect)
            }
            
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 34, weight: .bold),
                .foregroundColor: UIColor.white,
                .paragraphStyle: paragraphStyle
            ]
            let titleRect = CGRect(x: 40, y: 340, width: size.width - 80, height: 80)
            (title as NSString).draw(in: titleRect, withAttributes: titleAttributes)
            
            let artistAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 24, weight: .medium),
                .foregroundColor: UIColor(white: 0.75, alpha: 1.0),
                .paragraphStyle: paragraphStyle
            ]
            let artistRect = CGRect(x: 40, y: 420, width: size.width - 80, height: 50)
            (artist as NSString).draw(in: artistRect, withAttributes: artistAttributes)
        }
    }
}
