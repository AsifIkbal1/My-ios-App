import Foundation
import SwiftData

@Model
public final class PlaybackHistoryItem {
    @Attribute(.unique) public var id: String
    public var trackId: String
    public var trackTitle: String
    public var trackArtist: String
    public var artworkURLString: String?
    public var playedAt: Date
    public var completionRatio: Double
    
    public init(
        id: String = UUID().uuidString,
        trackId: String,
        trackTitle: String,
        trackArtist: String,
        artworkURLString: String? = nil,
        playedAt: Date = Date(),
        completionRatio: Double = 0.0
    ) {
        self.id = id
        self.trackId = trackId
        self.trackTitle = trackTitle
        self.trackArtist = trackArtist
        self.artworkURLString = artworkURLString
        self.playedAt = playedAt
        self.completionRatio = completionRatio
    }
}
