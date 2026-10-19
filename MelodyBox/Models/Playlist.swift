import Foundation
import SwiftData

@Model
public final class Playlist {
    @Attribute(.unique) public var id: String
    public var title: String
    public var playlistDescription: String
    public var createdAt: Date
    public var updatedAt: Date
    
    @Relationship(deleteRule: .nullify)
    public var tracks: [Track]
    
    @Attribute(.externalStorage)
    public var coverImageData: Data?
    
    public init(
        id: String = UUID().uuidString,
        title: String,
        playlistDescription: String = "",
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        tracks: [Track] = [],
        coverImageData: Data? = nil
    ) {
        self.id = id
        self.title = title
        self.playlistDescription = playlistDescription
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.tracks = tracks
        self.coverImageData = coverImageData
    }
    
    public var totalDuration: TimeInterval {
        tracks.reduce(0) { $0 + $1.duration }
    }
    
    public var formattedDuration: String {
        totalDuration.formattedDuration
    }
    
    public var trackCount: Int {
        tracks.count
    }
}
