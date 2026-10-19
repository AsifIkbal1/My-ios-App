import Foundation
import SwiftUI

// MARK: - Catalog Track Model
public struct CatalogTrack: Identifiable, Hashable {
    public let id: String
    public let title: String
    public let artist: String
    public let album: String
    public let duration: TimeInterval
    public let streamURL: URL
    public let downloadURL: URL?
    public let artworkURL: URL?
    public let licenseType: LicenseType
    public let licenseName: String
    public let licenseURL: URL?
    public let attribution: String
    public let genre: String
    
    public var isDownloadAllowed: Bool {
        return licenseType.isDownloadAllowed && downloadURL != nil
    }
    
    public init(
        id: String = UUID().uuidString,
        title: String,
        artist: String,
        album: String,
        duration: TimeInterval,
        streamURL: URL,
        downloadURL: URL? = nil,
        artworkURL: URL? = nil,
        licenseType: LicenseType = .creativeCommonsBy,
        licenseName: String? = nil,
        licenseURL: URL? = nil,
        attribution: String = "",
        genre: String = "Lawful Audio"
    ) {
        self.id = id
        self.title = title
        self.artist = artist
        self.album = album
        self.duration = duration
        self.streamURL = streamURL
        self.downloadURL = downloadURL ?? streamURL
        self.artworkURL = artworkURL
        self.licenseType = licenseType
        self.licenseName = licenseName ?? licenseType.displayName
        self.licenseURL = licenseURL
        self.attribution = attribution
        self.genre = genre
    }
    
    /// Converts catalog track into a SwiftData Track entity
    public func toTrackEntity() -> Track {
        return Track(
            id: id,
            title: title,
            artist: artist,
            album: album,
            duration: duration,
            remoteStreamURLString: streamURL.absoluteString,
            remoteArtworkURLString: artworkURL?.absoluteString,
            source: .catalogSearch,
            licenseType: licenseType,
            licenseName: licenseName,
            licenseURLString: licenseURL?.absoluteString,
            attributionText: attribution,
            isDownloaded: false
        )
    }
}

// MARK: - Catalog Genre Model
public struct CatalogGenre: Identifiable, Hashable {
    public let id: String
    public let name: String
    public let icon: String
    
    public init(id: String, name: String, icon: String) {
        self.id = id
        self.name = name
        self.icon = icon
    }
}

// MARK: - Music Catalog Provider Protocol
public protocol MusicCatalogProvider: AnyObject {
    var providerId: String { get }
    var providerName: String { get }
    var providerDescription: String { get }
    var providerIcon: String { get }
    
    func search(query: String) async throws -> [CatalogTrack]
    func fetchFeatured() async throws -> [CatalogTrack]
    func fetchGenres() async throws -> [CatalogGenre]
}
