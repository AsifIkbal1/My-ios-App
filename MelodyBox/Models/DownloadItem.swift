import Foundation
import SwiftData

public enum DownloadStatus: String, Codable, CaseIterable {
    case pending = "pending"
    case downloading = "downloading"
    case paused = "paused"
    case completed = "completed"
    case failed = "failed"
    case cancelled = "cancelled"
    
    public var label: String {
        switch self {
        case .pending: return "Queued"
        case .downloading: return "Downloading"
        case .paused: return "Paused"
        case .completed: return "Downloaded"
        case .failed: return "Failed"
        case .cancelled: return "Cancelled"
        }
    }
}

@Model
public final class DownloadItem {
    @Attribute(.unique) public var id: String
    public var originalURLString: String
    public var title: String
    public var artist: String
    public var album: String
    public var artworkURLString: String?
    public var statusRaw: String
    public var progress: Double // 0.0 to 1.0
    public var downloadedBytes: Int64
    public var totalBytes: Int64
    public var errorMessage: String?
    public var createdDate: Date
    public var destinationRelativePath: String?
    @Attribute(.externalStorage) public var resumeData: Data?
    public var licenseTypeRaw: String
    public var licenseName: String
    
    public init(
        id: String = UUID().uuidString,
        originalURLString: String,
        title: String,
        artist: String = "Unknown Artist",
        album: String = "Lawful Audio",
        artworkURLString: String? = nil,
        status: DownloadStatus = .pending,
        progress: Double = 0.0,
        downloadedBytes: Int64 = 0,
        totalBytes: Int64 = 0,
        errorMessage: String? = nil,
        createdDate: Date = Date(),
        destinationRelativePath: String? = nil,
        resumeData: Data? = nil,
        licenseType: LicenseType = .directAuthorized,
        licenseName: String? = nil
    ) {
        self.id = id
        self.originalURLString = originalURLString
        self.title = title
        self.artist = artist
        self.album = album
        self.artworkURLString = artworkURLString
        self.statusRaw = status.rawValue
        self.progress = progress
        self.downloadedBytes = downloadedBytes
        self.totalBytes = totalBytes
        self.errorMessage = errorMessage
        self.createdDate = createdDate
        self.destinationRelativePath = destinationRelativePath
        self.resumeData = resumeData
        self.licenseTypeRaw = licenseType.rawValue
        self.licenseName = licenseName ?? licenseType.displayName
    }
    
    public var status: DownloadStatus {
        get { DownloadStatus(rawValue: statusRaw) ?? .pending }
        set { statusRaw = newValue.rawValue }
    }
    
    public var licenseType: LicenseType {
        get { LicenseType(rawValue: licenseTypeRaw) ?? .directAuthorized }
        set { 
            licenseTypeRaw = newValue.rawValue 
            licenseName = newValue.displayName
        }
    }
    
    public var formattedProgress: String {
        let percent = Int(progress * 100)
        return "\(percent)%"
    }
    
    public var formattedBytesStatus: String {
        let current = ByteCountFormatter.string(fromByteCount: downloadedBytes, countStyle: .file)
        if totalBytes > 0 {
            let total = ByteCountFormatter.string(fromByteCount: totalBytes, countStyle: .file)
            return "\(current) / \(total)"
        }
        return current
    }
}
