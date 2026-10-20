import Foundation
import SwiftData
import SwiftUI

public enum TrackSource: String, Codable {
    case demoCatalog = "demoCatalog"
    case directUrl = "directUrl"
    case fileImport = "fileImport"
    case catalogSearch = "catalogSearch"
}

@Model
public final class Track {
    @Attribute(.unique) public var id: String
    public var title: String
    public var artist: String
    public var album: String
    public var duration: TimeInterval
    public var relativeFilePath: String?
    public var remoteStreamURLString: String?
    public var remoteArtworkURLString: String?
    @Attribute(.externalStorage) public var artworkData: Data?
    public var sourceRaw: String
    public var licenseTypeRaw: String
    public var licenseName: String
    public var licenseURLString: String?
    public var attributionText: String?
    public var addedDate: Date
    public var lastPlayedDate: Date?
    public var playCount: Int
    public var isFavorite: Bool
    public var isDownloaded: Bool
    public var fileSize: Int64
    public var mimeType: String?
    
    @Relationship(inverse: \Playlist.tracks)
    public var playlists: [Playlist]?
    
    public init(
        id: String = UUID().uuidString,
        title: String,
        artist: String = "Unknown Artist",
        album: String = "Unknown Album",
        duration: TimeInterval = 0,
        relativeFilePath: String? = nil,
        remoteStreamURLString: String? = nil,
        remoteArtworkURLString: String? = nil,
        artworkData: Data? = nil,
        source: TrackSource = .directUrl,
        licenseType: LicenseType = .directAuthorized,
        licenseName: String? = nil,
        licenseURLString: String? = nil,
        attributionText: String? = nil,
        addedDate: Date = Date(),
        lastPlayedDate: Date? = nil,
        playCount: Int = 0,
        isFavorite: Bool = false,
        isDownloaded: Bool = false,
        fileSize: Int64 = 0,
        mimeType: String? = "audio/mpeg"
    ) {
        self.id = id
        self.title = title
        self.artist = artist
        self.album = album
        self.duration = duration
        self.relativeFilePath = relativeFilePath
        self.remoteStreamURLString = remoteStreamURLString
        self.remoteArtworkURLString = remoteArtworkURLString
        self.artworkData = artworkData
        self.sourceRaw = source.rawValue
        self.licenseTypeRaw = licenseType.rawValue
        self.licenseName = licenseName ?? licenseType.displayName
        self.licenseURLString = licenseURLString
        self.attributionText = attributionText
        self.addedDate = addedDate
        self.lastPlayedDate = lastPlayedDate
        self.playCount = playCount
        self.isFavorite = isFavorite
        self.isDownloaded = isDownloaded
        self.fileSize = fileSize
        self.mimeType = mimeType
        self.playlists = []
    }
    
    public var source: TrackSource {
        get { TrackSource(rawValue: sourceRaw) ?? .directUrl }
        set { sourceRaw = newValue.rawValue }
    }
    
    public var licenseType: LicenseType {
        get { LicenseType(rawValue: licenseTypeRaw) ?? .directAuthorized }
        set { 
            licenseTypeRaw = newValue.rawValue 
            licenseName = newValue.displayName
        }
    }
    
    /// Resolves the absolute local URL for offline playback inside the app sandbox
    public var resolvedLocalFileURL: URL? {
        guard let relativeFilePath = relativeFilePath else { return nil }
        
        // If it starts with "bundle://", resolve from main bundle
        if relativeFilePath.hasPrefix("bundle://") {
            let resourceName = String(relativeFilePath.dropFirst("bundle://".count))
            let ext = (resourceName as NSString).pathExtension
            let base = (resourceName as NSString).deletingPathExtension
            return Bundle.main.url(forResource: base, withExtension: ext)
        }
        
        // Otherwise resolve in Documents directory
        guard let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        let fileURL = docs.appendingPathComponent(relativeFilePath)
        return FileManager.default.fileExists(atPath: fileURL.path) ? fileURL : nil
    }
    
    /// Primary playback URL: returns offline local file if available, or streaming URL
    public var playbackURL: URL? {
        if let local = resolvedLocalFileURL {
            return local
        }
        if let remoteStr = remoteStreamURLString {
            if remoteStr.hasPrefix("bundle://") {
                let resourceName = String(remoteStr.dropFirst("bundle://".count))
                let ext = (resourceName as NSString).pathExtension
                let base = (resourceName as NSString).deletingPathExtension
                return Bundle.main.url(forResource: base, withExtension: ext)
            }
            if let remote = URL(string: remoteStr) {
                return remote
            }
        }
        return nil
    }
    
    public var formattedDuration: String {
        duration.formattedDuration
    }
    
    public var formattedFileSize: String {
        ByteCountFormatter.string(fromByteCount: fileSize, countStyle: .file)
    }
    
    public var genreOrFormat: String {
        if isDownloaded {
            return "OFFLINE AUDIO"
        }
        return licenseName.uppercased()
    }
}
