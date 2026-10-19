import SwiftUI
import SwiftData

@main
struct MelodyBoxApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    let sharedModelContainer: ModelContainer
    
    init() {
        do {
            let schema = Schema([
                Track.self,
                Playlist.self,
                DownloadItem.self,
                PlaybackHistoryItem.self
            ])
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            self.sharedModelContainer = container
            
            // Connect model container to download manager for background persistence
            BackgroundDownloadManager.shared.modelContainer = container
        } catch {
            fatalError("Failed to initialize SwiftData ModelContainer: \(error.localizedDescription)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .preferredColorScheme(.dark)
        }
        .modelContainer(sharedModelContainer)
    }
}
