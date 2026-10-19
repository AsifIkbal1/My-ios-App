import Foundation
import AVFoundation
import SwiftData
import UIKit

public final class FileImportService {
    public static let shared = FileImportService()
    
    private init() {}
    
    /// Imports audio files from security-scoped URLs (e.g. from Files app or Document Picker)
    public func importAudioFiles(from urls: [URL], into context: ModelContext) async throws -> [Track] {
        var importedTracks: [Track] = []
        let tracksDir = StorageManager.shared.tracksDirectoryURL
        
        for url in urls {
            // Secure access for sandboxed document picker
            let hasAccess = url.startAccessingSecurityScopedResource()
            defer {
                if hasAccess {
                    url.stopAccessingSecurityScopedResource()
                }
            }
            
            let fileExtension = url.pathExtension.lowercased()
            let allowedExtensions = ["mp3", "m4a", "wav", "aac", "aiff", "flac"]
            guard allowedExtensions.contains(fileExtension) else {
                continue
            }
            
            let uniqueId = UUID().uuidString
            let destinationFilename = "\(uniqueId).\(fileExtension)"
            let destinationURL = tracksDir.appendingPathComponent(destinationFilename)
            let relativePath = "Tracks/\(destinationFilename)"
            
            do {
                if FileManager.default.fileExists(atPath: destinationURL.path) {
                    try FileManager.default.removeItem(at: destinationURL)
                }
                try FileManager.default.copyItem(at: url, to: destinationURL)
                
                // Get file size
                let attrs = try FileManager.default.attributesOfItem(atPath: destinationURL.path)
                let fileSize = (attrs[.size] as? Int64) ?? 0
                
                // Load metadata with AVAsset
                let asset = AVURLAsset(url: destinationURL)
                var duration: TimeInterval = 0
                if let d = try? await asset.load(.duration) {
                    duration = d.seconds
                }
                
                var title = url.deletingPathExtension().lastPathComponent
                var artist = "Local Artist"
                var album = "Imported Audio"
                var artworkData: Data? = nil
                
                if let metadata = try? await asset.load(.commonMetadata) {
                    for item in metadata {
                        if let key = item.commonKey {
                            switch key {
                            case .commonKeyTitle:
                                if let val = try? await item.load(.stringValue), !val.trimmingCharacters(in: .whitespaces).isEmpty {
                                    title = val
                                }
                            case .commonKeyArtist:
                                if let val = try? await item.load(.stringValue), !val.trimmingCharacters(in: .whitespaces).isEmpty {
                                    artist = val
                                }
                            case .commonKeyAlbumName:
                                if let val = try? await item.load(.stringValue), !val.trimmingCharacters(in: .whitespaces).isEmpty {
                                    album = val
                                }
                            case .commonKeyArtwork:
                                artworkData = try? await item.load(.dataValue)
                            default:
                                break
                            }
                        }
                    }
                }
                
                let track = Track(
                    id: uniqueId,
                    title: title,
                    artist: artist,
                    album: album,
                    duration: duration > 0 ? duration : 0,
                    relativeFilePath: relativePath,
                    artworkData: artworkData,
                    source: .fileImport,
                    licenseType: .directAuthorized,
                    licenseName: "Personal Imported Audio",
                    isDownloaded: true,
                    fileSize: fileSize,
                    mimeType: "audio/\(fileExtension)"
                )
                
                context.insert(track)
                importedTracks.append(track)
            } catch {
                print("Failed to import file \(url.lastPathComponent): \(error)")
            }
        }
        
        try? context.save()
        return importedTracks
    }
}
