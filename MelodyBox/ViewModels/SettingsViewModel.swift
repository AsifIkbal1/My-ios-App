import SwiftUI
import SwiftData
import Observation

@Observable
public final class SettingsViewModel {
    private let wifiOnlyKey = "MelodyBox.WifiOnlyDownloads"
    
    public var isWifiOnly: Bool {
        didSet {
            UserDefaults.standard.set(isWifiOnly, forKey: wifiOnlyKey)
            BackgroundDownloadManager.shared.allowsCellularAccess = !isWifiOnly
        }
    }
    
    public var storageUsedFormatted: String = "0 B"
    public var storageAvailableFormatted: String = "0 B"
    public var isClearStorageAlertPresented: Bool = false
    public var isLegalSheetPresented: Bool = false
    
    public init() {
        let savedWifiOnly = UserDefaults.standard.bool(forKey: wifiOnlyKey)
        self.isWifiOnly = savedWifiOnly
        BackgroundDownloadManager.shared.allowsCellularAccess = !savedWifiOnly
        refreshStorageInfo()
    }
    
    public func refreshStorageInfo() {
        storageUsedFormatted = StorageManager.shared.formattedStorageUsage()
        storageAvailableFormatted = StorageManager.shared.formattedAvailableSpace()
    }
    
    public func clearAllDownloads(context: ModelContext) {
        StorageManager.shared.clearAllDownloadedFiles(context: context)
        refreshStorageInfo()
    }
}
