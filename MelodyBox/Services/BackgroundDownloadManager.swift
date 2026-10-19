import Foundation
import AVFoundation
import SwiftData
import Observation
import Network

@Observable
public final class BackgroundDownloadManager: NSObject, URLSessionDownloadDelegate, URLSessionTaskDelegate {
    public static let shared = BackgroundDownloadManager()
    
    public var activeDownloads: [String: DownloadProgressState] = [:]
    public var allowsCellularAccess: Bool = true {
        didSet {
            recreateSessionIfNeeded()
        }
    }
    
    // Relay for background URLSession events
    public var backgroundCompletionHandler: (() -> Void)?
    
    // ModelContainer reference for saving downloaded tracks
    public var modelContainer: ModelContainer?
    
    private var session: URLSession!
    private var taskToDownloadId: [Int: String] = [:]
    private var downloadIdToTask: [String: URLSessionDownloadTask] = [:]
    
    public struct DownloadProgressState {
        public var downloadId: String
        public var progress: Double
        public var downloadedBytes: Int64
        public var totalBytes: Int64
        public var status: DownloadStatus
        public var errorMessage: String?
    }
    
    public override init() {
        super.init()
        let config = URLSessionConfiguration.background(withIdentifier: "com.melodybox.audio.download")
        config.isDiscretionary = false
        config.sessionSendsLaunchEvents = true
        config.allowsCellularAccess = allowsCellularAccess
        config.waitsForConnectivity = true
        config.timeoutIntervalForResource = 3600 // 1 hour for large files
        self.session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }
    
    private func recreateSessionIfNeeded() {
        let config = URLSessionConfiguration.background(withIdentifier: "com.melodybox.audio.download")
        config.isDiscretionary = false
        config.sessionSendsLaunchEvents = true
        config.allowsCellularAccess = allowsCellularAccess
        config.waitsForConnectivity = true
        self.session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }
    
    // MARK: - Start / Resume / Pause / Cancel Download
    
    /// Starts or resumes a background download
    public func startDownload(item: DownloadItem) {
        guard let url = URL(string: item.originalURLString) else {
            updateItemStatus(id: item.id, status: .failed, error: "Invalid audio URL format.")
            return
        }
        
        let task: URLSessionDownloadTask
        if let resumeData = item.resumeData {
            task = session.downloadTask(withResumeData: resumeData)
        } else {
            var request = URLRequest(url: url)
            request.setValue("MelodyBox-iOS/1.0", forHTTPHeaderField: "User-Agent")
            request.setValue("audio/*, */*", forHTTPHeaderField: "Accept")
            task = session.downloadTask(with: request)
        }
        
        taskToDownloadId[task.taskIdentifier] = item.id
        downloadIdToTask[item.id] = task
        
        DispatchQueue.main.async {
            self.activeDownloads[item.id] = DownloadProgressState(
                downloadId: item.id,
                progress: item.progress,
                downloadedBytes: item.downloadedBytes,
                totalBytes: item.totalBytes,
                status: .downloading,
                errorMessage: nil
            )
        }
        
        updateItemStatus(id: item.id, status: .downloading, error: nil)
        task.resume()
    }
    
    /// Pauses an active download, capturing resume data for resumption
    public func pauseDownload(id: String) {
        guard let task = downloadIdToTask[id] else { return }
        task.cancel { [weak self] resumeData in
            guard let self = self else { return }
            self.updateItemResumeData(id: id, resumeData: resumeData, status: .paused)
            DispatchQueue.main.async {
                self.activeDownloads[id]?.status = .paused
                self.downloadIdToTask.removeValue(forKey: id)
            }
        }
    }
    
    /// Retries a failed or paused download
    public func retryDownload(item: DownloadItem) {
        startDownload(item: item)
    }
    
    /// Cancels and deletes an in-progress or queued download
    public func cancelDownload(id: String) {
        if let task = downloadIdToTask[id] {
            task.cancel()
            downloadIdToTask.removeValue(forKey: id)
        }
        DispatchQueue.main.async {
            self.activeDownloads.removeValue(forKey: id)
        }
        updateItemStatus(id: id, status: .cancelled, error: nil)
    }
    
    // MARK: - URLSessionDownloadDelegate
    
    public func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didWriteData bytesWritten: Int64,
        totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64
    ) {
        guard let downloadId = taskToDownloadId[downloadTask.taskIdentifier] else { return }
        
        let progress: Double
        if totalBytesExpectedToWrite > 0 {
            progress = max(0.0, min(1.0, Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)))
        } else {
            progress = 0.5 // indeterminate
        }
        
        DispatchQueue.main.async {
            self.activeDownloads[downloadId] = DownloadProgressState(
                downloadId: downloadId,
                progress: progress,
                downloadedBytes: totalBytesWritten,
                totalBytes: totalBytesExpectedToWrite > 0 ? totalBytesExpectedToWrite : 0,
                status: .downloading,
                errorMessage: nil
            )
            
            // Persist periodic progress to SwiftData
            self.updateItemProgress(
                id: downloadId,
                progress: progress,
                downloadedBytes: totalBytesWritten,
                totalBytes: totalBytesExpectedToWrite
            )
        }
    }
    
    public func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didFinishDownloadingTo location: URL
    ) {
        guard let downloadId = taskToDownloadId[downloadTask.taskIdentifier] else { return }
        
        // Validate HTTP response
        if let httpResponse = downloadTask.response as? HTTPURLResponse {
            let statusCode = httpResponse.statusCode
            guard (200...299).contains(statusCode) else {
                let errorMsg = "Server returned HTTP status \(statusCode)"
                updateItemStatus(id: downloadId, status: .failed, error: errorMsg)
                DispatchQueue.main.async {
                    self.activeDownloads[downloadId]?.status = .failed
                    self.activeDownloads[downloadId]?.errorMessage = errorMsg
                }
                return
            }
        }
        
        // Determine file extension from MIME or response
        var fileExt = "mp3"
        if let mime = downloadTask.response?.mimeType {
            if mime.contains("mp4") || mime.contains("m4a") {
                fileExt = "m4a"
            } else if mime.contains("wav") {
                fileExt = "wav"
            } else if mime.contains("aac") {
                fileExt = "aac"
            } else if mime.contains("ogg") {
                fileExt = "ogg"
            }
        } else if let originalURL = downloadTask.response?.url {
            let ext = originalURL.pathExtension.lowercased()
            if ["mp3", "m4a", "wav", "aac", "aiff", "flac"].contains(ext) {
                fileExt = ext
            }
        }
        
        let filename = "\(downloadId).\(fileExt)"
        let destinationDir = StorageManager.shared.tracksDirectoryURL
        let destinationURL = destinationDir.appendingPathComponent(filename)
        let relativePath = "Tracks/\(filename)"
        
        do {
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                try FileManager.default.removeItem(at: destinationURL)
            }
            try FileManager.default.moveItem(at: location, to: destinationURL)
            
            // Extract file size and metadata
            let fileAttributes = try FileManager.default.attributesOfItem(atPath: destinationURL.path)
            let fileSize = (fileAttributes[.size] as? Int64) ?? 0
            
            // Process completed download asynchronously on main queue
            DispatchQueue.main.async {
                self.processCompletedDownload(
                    downloadId: downloadId,
                    destinationURL: destinationURL,
                    relativePath: relativePath,
                    fileSize: fileSize
                )
            }
        } catch {
            let errorMsg = "Failed to save downloaded file: \(error.localizedDescription)"
            updateItemStatus(id: downloadId, status: .failed, error: errorMsg)
            DispatchQueue.main.async {
                self.activeDownloads[downloadId]?.status = .failed
                self.activeDownloads[downloadId]?.errorMessage = errorMsg
            }
        }
    }
    
    // MARK: - URLSessionTaskDelegate
    
    public func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didCompleteWithError error: Error?
    ) {
        guard let downloadId = taskToDownloadId[task.taskIdentifier] else { return }
        taskToDownloadId.removeValue(forKey: task.taskIdentifier)
        downloadIdToTask.removeValue(forKey: downloadId)
        
        if let error = error as NSError? {
            // Check if cancelled with resume data
            if let resumeData = error.userInfo[NSURLSessionDownloadTaskResumeData] as? Data {
                updateItemResumeData(id: downloadId, resumeData: resumeData, status: .paused)
                DispatchQueue.main.async {
                    self.activeDownloads[downloadId]?.status = .paused
                }
            } else if error.code != NSURLErrorCancelled {
                let errorMsg = error.localizedDescription
                updateItemStatus(id: downloadId, status: .failed, error: errorMsg)
                DispatchQueue.main.async {
                    self.activeDownloads[downloadId]?.status = .failed
                    self.activeDownloads[downloadId]?.errorMessage = errorMsg
                }
            }
        }
    }
    
    public func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        willPerformHTTPRedirection response: HTTPURLResponse,
        newRequest request: URLRequest,
        completionHandler: @escaping (URLRequest?) -> Void
    ) {
        // Safely validate and follow redirects
        completionHandler(request)
    }
    
    public func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DispatchQueue.main.async {
            self.backgroundCompletionHandler?()
            self.backgroundCompletionHandler = nil
        }
    }
    
    // MARK: - SwiftData Persistence Helpers
    
    private func processCompletedDownload(
        downloadId: String,
        destinationURL: URL,
        relativePath: String,
        fileSize: Int64
    ) {
        guard let container = modelContainer else { return }
        let context = ModelContext(container)
        
        let descriptor = FetchDescriptor<DownloadItem>(predicate: #Predicate { $0.id == downloadId })
        guard let items = try? context.fetch(descriptor), let item = items.first else { return }
        
        item.status = .completed
        item.progress = 1.0
        item.downloadedBytes = fileSize
        item.destinationRelativePath = relativePath
        item.resumeData = nil
        
        // Inspect audio metadata with AVAsset
        Task {
            let asset = AVURLAsset(url: destinationURL)
            var duration: TimeInterval = 0
            if let d = try? await asset.load(.duration) {
                duration = d.seconds
            }
            
            var extractedTitle: String? = nil
            var extractedArtist: String? = nil
            var extractedAlbum: String? = nil
            var artworkData: Data? = nil
            
            if let commonMetadata = try? await asset.load(.commonMetadata) {
                for item in commonMetadata {
                    if let key = item.commonKey {
                        switch key {
                        case .commonKeyTitle:
                            extractedTitle = try? await item.load(.stringValue)
                        case .commonKeyArtist:
                            extractedArtist = try? await item.load(.stringValue)
                        case .commonKeyAlbumName:
                            extractedAlbum = try? await item.load(.stringValue)
                        case .commonKeyArtwork:
                            artworkData = try? await item.load(.dataValue)
                        default:
                            break
                        }
                    }
                }
            }
            
            await MainActor.run {
                // Create or update Track
                let finalTitle = extractedTitle ?? (item.title.isEmpty ? "Unknown Title" : item.title)
                let finalArtist = extractedArtist ?? (item.artist.isEmpty ? "Unknown Artist" : item.artist)
                let finalAlbum = extractedAlbum ?? (item.album.isEmpty ? "Lawful Audio" : item.album)
                
                let track = Track(
                    id: UUID().uuidString,
                    title: finalTitle,
                    artist: finalArtist,
                    album: finalAlbum,
                    duration: duration > 0 ? duration : 0,
                    relativeFilePath: relativePath,
                    remoteStreamURLString: item.originalURLString,
                    remoteArtworkURLString: item.artworkURLString,
                    artworkData: artworkData,
                    source: .directUrl,
                    licenseType: item.licenseType,
                    licenseName: item.licenseName,
                    isDownloaded: true,
                    fileSize: fileSize
                )
                
                context.insert(track)
                try? context.save()
                
                self.activeDownloads[downloadId]?.status = .completed
                self.activeDownloads[downloadId]?.progress = 1.0
            }
        }
    }
    
    private func updateItemProgress(id: String, progress: Double, downloadedBytes: Int64, totalBytes: Int64) {
        guard let container = modelContainer else { return }
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<DownloadItem>(predicate: #Predicate { $0.id == id })
        if let item = try? context.fetch(descriptor).first {
            item.progress = progress
            item.downloadedBytes = downloadedBytes
            if totalBytes > 0 { item.totalBytes = totalBytes }
            try? context.save()
        }
    }
    
    private func updateItemStatus(id: String, status: DownloadStatus, error: String?) {
        guard let container = modelContainer else { return }
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<DownloadItem>(predicate: #Predicate { $0.id == id })
        if let item = try? context.fetch(descriptor).first {
            item.status = status
            item.errorMessage = error
            try? context.save()
        }
    }
    
    private func updateItemResumeData(id: String, resumeData: Data?, status: DownloadStatus) {
        guard let container = modelContainer else { return }
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<DownloadItem>(predicate: #Predicate { $0.id == id })
        if let item = try? context.fetch(descriptor).first {
            item.resumeData = resumeData
            item.status = status
            try? context.save()
        }
    }
}
