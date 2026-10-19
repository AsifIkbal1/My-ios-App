import SwiftUI
import SwiftData
import Observation

@Observable
public final class DownloaderViewModel {
    public var isDirectURLSheetPresented: Bool = false
    public var inputURLString: String = ""
    public var inputTitle: String = ""
    public var inputArtist: String = ""
    public var selectedLicense: LicenseType = .directAuthorized
    public var validationErrorMessage: String? = nil
    public var isValidatingURL: Bool = false
    
    public init() {}
    
    public func validateAndStartDirectDownload(context: ModelContext) {
        let trimmedURL = inputURLString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedURL.isEmpty else {
            validationErrorMessage = "Please enter an audio URL."
            return
        }
        
        guard let url = URL(string: trimmedURL),
              let scheme = url.scheme?.lowercased(),
              (scheme == "https" || scheme == "http") else {
            validationErrorMessage = "Invalid URL. Please provide a valid HTTP or HTTPS audio link."
            return
        }
        
        isValidatingURL = true
        validationErrorMessage = nil
        
        Task {
            var request = URLRequest(url: url)
            request.httpMethod = "HEAD"
            request.timeoutInterval = 10
            
            do {
                let (_, response) = try await URLSession.shared.data(for: request)
                if let httpResponse = response as? HTTPURLResponse {
                    guard (200...399).contains(httpResponse.statusCode) else {
                        await MainActor.run {
                            self.validationErrorMessage = "Remote server returned HTTP \(httpResponse.statusCode)."
                            self.isValidatingURL = false
                        }
                        return
                    }
                }
                
                await MainActor.run {
                    self.enqueueDownload(url: url, context: context)
                    self.isValidatingURL = false
                    self.isDirectURLSheetPresented = false
                    self.resetFields()
                }
            } catch {
                // If HEAD fails, attempt direct enqueue anyway
                await MainActor.run {
                    self.enqueueDownload(url: url, context: context)
                    self.isValidatingURL = false
                    self.isDirectURLSheetPresented = false
                    self.resetFields()
                }
            }
        }
    }
    
    private func enqueueDownload(url: URL, context: ModelContext) {
        let title = inputTitle.trimmingCharacters(in: .whitespaces).isEmpty
            ? url.deletingPathExtension().lastPathComponent
            : inputTitle.trimmingCharacters(in: .whitespaces)
        
        let artist = inputArtist.trimmingCharacters(in: .whitespaces).isEmpty
            ? "Direct Audio Source"
            : inputArtist.trimmingCharacters(in: .whitespaces)
        
        let downloadItem = DownloadItem(
            id: UUID().uuidString,
            originalURLString: url.absoluteString,
            title: title,
            artist: artist,
            album: "Direct Downloads",
            licenseType: selectedLicense,
            licenseName: selectedLicense.displayName
        )
        
        context.insert(downloadItem)
        try? context.save()
        
        BackgroundDownloadManager.shared.startDownload(item: downloadItem)
    }
    
    public func pauseDownload(id: String) {
        BackgroundDownloadManager.shared.pauseDownload(id: id)
    }
    
    public func resumeDownload(item: DownloadItem) {
        BackgroundDownloadManager.shared.startDownload(item: item)
    }
    
    public func retryDownload(item: DownloadItem) {
        BackgroundDownloadManager.shared.retryDownload(item: item)
    }
    
    public func cancelAndDelete(item: DownloadItem, context: ModelContext) {
        BackgroundDownloadManager.shared.cancelDownload(id: item.id)
        if let relPath = item.destinationRelativePath {
            StorageManager.shared.deleteTrackFile(relativeFilePath: relPath)
        }
        context.delete(item)
        try? context.save()
    }
    
    private func resetFields() {
        inputURLString = ""
        inputTitle = ""
        inputArtist = ""
        selectedLicense = .directAuthorized
        validationErrorMessage = nil
    }
}
