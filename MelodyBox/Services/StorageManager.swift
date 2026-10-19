import Foundation
import SwiftData

public final class StorageManager {
    public static let shared = StorageManager()
    
    private init() {}
    
    /// The directory where downloaded tracks are persisted: <Documents>/Tracks
    public var tracksDirectoryURL: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let tracksDir = docs.appendingPathComponent("Tracks", isDirectory: true)
        if !FileManager.default.fileExists(atPath: tracksDir.path) {
            try? FileManager.default.createDirectory(at: tracksDir, withIntermediateDirectories: true)
        }
        return tracksDir
    }
    
    /// Computes total storage in bytes consumed by downloaded audio tracks
    public func calculateTracksStorageBytes() -> Int64 {
        let url = tracksDirectoryURL
        let resourceKeys: Set<URLResourceKey> = [.fileSizeKey, .isDirectoryKey]
        guard let enumerator = FileManager.default.enumerator(
            at: url,
            includingPropertiesForKeys: Array(resourceKeys),
            options: [.skipsHiddenFiles]
        ) else {
            return 0
        }
        
        var totalBytes: Int64 = 0
        for case let fileURL as URL in enumerator {
            guard let resourceValues = try? fileURL.resourceValues(forKeys: resourceKeys),
                  let isDirectory = resourceValues.isDirectory, !isDirectory,
                  let size = resourceValues.fileSize else {
                continue
            }
            totalBytes += Int64(size)
        }
        return totalBytes
    }
    
    /// Human readable storage usage string (e.g. "42.8 MB")
    public func formattedStorageUsage() -> String {
        let bytes = calculateTracksStorageBytes()
        return ByteCountFormatter.string(fromByteCount: bytes, countStyle: .file)
    }
    
    /// Available device free space in bytes
    public func getAvailableDeviceSpaceBytes() -> Int64 {
        let url = tracksDirectoryURL
        if let values = try? url.resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey]),
           let capacity = values.volumeAvailableCapacityForImportantUsage {
            return capacity
        }
        return 0
    }
    
    public func formattedAvailableSpace() -> String {
        let bytes = getAvailableDeviceSpaceBytes()
        return ByteCountFormatter.string(fromByteCount: bytes, countStyle: .file)
    }
    
    /// Clears all downloaded audio files from disk and updates Track records
    public func clearAllDownloadedFiles(context: ModelContext) {
        let dir = tracksDirectoryURL
        if let contents = try? FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil) {
            for file in contents {
                try? FileManager.default.removeItem(at: file)
            }
        }
        
        // Update SwiftData tracks
        let descriptor = FetchDescriptor<Track>(predicate: #Predicate { $0.isDownloaded == true })
        if let downloadedTracks = try? context.fetch(descriptor) {
            for track in downloadedTracks {
                track.isDownloaded = false
                track.relativeFilePath = nil
            }
            try? context.save()
        }
    }
    
    /// Deletes a specific audio file from local storage
    public func deleteTrackFile(relativeFilePath: String?) {
        guard let relativeFilePath = relativeFilePath, !relativeFilePath.hasPrefix("bundle://") else { return }
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = docs.appendingPathComponent(relativeFilePath)
        if FileManager.default.fileExists(atPath: fileURL.path) {
            try? FileManager.default.removeItem(at: fileURL)
        }
    }
}
