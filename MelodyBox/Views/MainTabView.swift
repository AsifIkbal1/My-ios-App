import SwiftUI
import SwiftData

public struct MainTabView: View {
    @State private var selectedTab: Int = 0
    @Bindable var playerVM: PlayerViewModel = .shared
    @Environment(\.modelContext) private var modelContext
    
    @Query private var allTracks: [Track]
    
    public init() {
        // Customize UITabBar dark appearance
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 0.05, green: 0.04, blue: 0.08, alpha: 0.95)
        
        // Active item
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(red: 0.66, green: 0.33, blue: 0.97, alpha: 1.0)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(red: 0.66, green: 0.33, blue: 0.97, alpha: 1.0),
            .font: UIFont.systemFont(ofSize: 10, weight: .bold)
        ]
        
        // Normal item
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(white: 0.5, alpha: 1.0)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor(white: 0.5, alpha: 1.0),
            .font: UIFont.systemFont(ofSize: 10, weight: .medium)
        ]
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    public var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                HomeView()
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                    .tag(0)
                
                SearchView()
                    .tabItem {
                        Label("Discover", systemImage: "sparkle.magnifyingglass")
                    }
                    .tag(1)
                
                LibraryView()
                    .tabItem {
                        Label("Library", systemImage: "books.vertical.fill")
                    }
                    .tag(2)
                
                DownloaderView()
                    .tabItem {
                        Label("Downloads", systemImage: "arrow.down.circle.fill")
                    }
                    .tag(3)
                
                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gearshape.fill")
                    }
                    .tag(4)
            }
            .tint(Theme.purple)
            
            // Floating Mini Player (Attached above the tab bar)
            if playerVM.currentTrack != nil {
                MiniPlayerBar()
                    .padding(.bottom, 49) // Align directly above iOS standard tab bar height
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .onAppear {
            // Seed starter lawful offline demo tracks on first launch
            DemoCatalogProvider.shared.seedInitialTracksIfNeeded(context: modelContext)
            
            // Restore last playback state
            AudioPlayerService.shared.restoreLastPlaybackState(from: allTracks)
        }
    }
}
