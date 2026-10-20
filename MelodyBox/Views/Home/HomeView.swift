import SwiftUI
import SwiftData
import UniformTypeIdentifiers

public struct HomeView: View {
    @Bindable var playerVM: PlayerViewModel = .shared
    @State private var homeVM = HomeViewModel()
    @Environment(\.modelContext) private var modelContext
    
    // SwiftData Queries
    @Query(filter: #Predicate<Track> { $0.isFavorite == true }, sort: \Track.addedDate, order: .reverse)
    private var favoriteTracks: [Track]
    
    @Query(filter: #Predicate<Track> { $0.isDownloaded == true }, sort: \Track.addedDate, order: .reverse)
    private var downloadedTracks: [Track]
    
    @Query(sort: \Track.lastPlayedDate, order: .reverse)
    private var allTracksByLastPlayed: [Track]
    
    // Quick Sheet triggers
    @State private var isFileImporterPresented: Bool = false
    @State private var isDirectURLPresented: Bool = false
    
    private var recentlyPlayedTracks: [Track] {
        allTracksByLastPlayed.filter { $0.lastPlayedDate != nil }
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Theme.backgroundGradient.ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        // Header
                        HStack(alignment: .center) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("MelodyBox")
                                    .font(.system(size: 28, weight: .black))
                                    .foregroundStyle(Theme.purpleGradient)
                                
                                Text("Discover • Lawfully Download • Play Offline")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(Theme.textSecondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "music.note.house.fill")
                                .font(.system(size: 24))
                                .foregroundColor(Theme.purple)
                                .padding(10)
                                .background(Circle().fill(Theme.surfaceElevated))
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        
                        // Quick Action Buttons
                        HStack(spacing: 12) {
                            QuickActionButton(
                                icon: "folder.badge.plus",
                                title: "Import Files",
                                action: { isFileImporterPresented = true }
                            )
                            
                            QuickActionButton(
                                icon: "link.badge.plus",
                                title: "Direct URL",
                                action: { isDirectURLPresented = true }
                            )
                        }
                        .padding(.horizontal, 20)
                        
                        // Featured Hero Section
                        if let featured = homeVM.featuredTracks.first {
                            FeaturedHeroView(
                                track: featured,
                                onPlay: {
                                    playerVM.play(track: featured.toTrackEntity())
                                },
                                onDownload: {
                                    SearchViewModel().queueDownload(for: featured, context: modelContext)
                                }
                            )
                            .padding(.horizontal, 20)
                        }
                        
                        // Recently Played Section
                        if !recentlyPlayedTracks.isEmpty {
                            SectionHeader(title: "Recently Played", count: recentlyPlayedTracks.count)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                LazyHStack(spacing: 14) {
                                    ForEach(recentlyPlayedTracks.prefix(10)) { track in
                                        TrackCardView(
                                            title: track.title,
                                            artist: track.artist,
                                            artworkData: track.artworkData,
                                            licenseType: track.licenseType,
                                            isDownloaded: track.isDownloaded,
                                            onPlay: {
                                                playerVM.play(track: track, from: recentlyPlayedTracks)
                                            }
                                        )
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                        
                        // Downloaded Offline Section
                        if !downloadedTracks.isEmpty {
                            SectionHeader(title: "Downloaded for Offline", count: downloadedTracks.count)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                LazyHStack(spacing: 14) {
                                    ForEach(downloadedTracks.prefix(10)) { track in
                                        TrackCardView(
                                            title: track.title,
                                            artist: track.artist,
                                            artworkData: track.artworkData,
                                            licenseType: track.licenseType,
                                            isDownloaded: true,
                                            onPlay: {
                                                playerVM.play(track: track, from: downloadedTracks)
                                            }
                                        )
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                        
                        // Favorites Section
                        if !favoriteTracks.isEmpty {
                            SectionHeader(title: "Your Favorites", count: favoriteTracks.count)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                LazyHStack(spacing: 14) {
                                    ForEach(favoriteTracks.prefix(10)) { track in
                                        TrackCardView(
                                            title: track.title,
                                            artist: track.artist,
                                            artworkData: track.artworkData,
                                            licenseType: track.licenseType,
                                            isDownloaded: track.isDownloaded,
                                            onPlay: {
                                                playerVM.play(track: track, from: favoriteTracks)
                                            }
                                        )
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                        
                        // Lawful Open Catalog Showcase
                        if homeVM.featuredTracks.count > 1 {
                            SectionHeader(title: "Lawful Creative Commons Showcase", count: homeVM.featuredTracks.count - 1)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                LazyHStack(spacing: 14) {
                                    ForEach(homeVM.featuredTracks.dropFirst().prefix(10)) { catalogTrack in
                                        TrackCardView(
                                            title: catalogTrack.title,
                                            artist: catalogTrack.artist,
                                            artworkURL: catalogTrack.artworkURL,
                                            licenseType: catalogTrack.licenseType,
                                            isDownloaded: false,
                                            onPlay: {
                                                playerVM.play(track: catalogTrack.toTrackEntity())
                                            }
                                        )
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                        
                        // Bottom Padding for mini player clearance
                        Spacer(minLength: 80)
                    }
                    .padding(.vertical, 12)
                }
            }
            .navigationBarHidden(true)
            .task {
                await homeVM.loadFeatured()
            }
            .fileImporter(
                isPresented: $isFileImporterPresented,
                allowedContentTypes: [.audio, .mp3, .mpeg4Audio, .wav, .aiff],
                allowsMultipleSelection: true
            ) { result in
                LibraryViewModel().handleFileImport(result: result, context: modelContext)
            }
            .sheet(isPresented: $isDirectURLPresented) {
                DirectURLImportSheet()
            }
        }
    }
}

public struct SectionHeader: View {
    public let title: String
    public let count: Int?
    
    public init(title: String, count: Int? = nil) {
        self.title = title
        self.count = count
    }
    
    public var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Theme.textPrimary)
            
            if let count = count {
                Text("\(count)")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Theme.purple)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Capsule().fill(Theme.purple.opacity(0.15)))
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
    }
}

public struct QuickActionButton: View {
    public let icon: String
    public let title: String
    public let action: () -> Void
    
    public var body: some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            action()
        }) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Theme.purple)
                
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Theme.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Theme.surfaceElevated.opacity(0.8))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(Theme.surfaceBorder, lineWidth: 1)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}
