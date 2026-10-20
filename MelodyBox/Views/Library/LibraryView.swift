import SwiftUI
import SwiftData
import UniformTypeIdentifiers

public struct LibraryView: View {
    @State private var libraryVM = LibraryViewModel()
    @Bindable var playerVM: PlayerViewModel = .shared
    @Environment(\.modelContext) private var modelContext
    
    @Query private var allTracks: [Track]
    @State private var activeTab: Int = 0 // 0: Tracks, 1: Playlists
    
    private var displayedTracks: [Track] {
        libraryVM.filterTracks(allTracks)
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Theme.backgroundGradient.ignoresSafeArea()
                
                VStack(spacing: 16) {
                    // Segmented Control (Tracks vs Playlists)
                    Picker("Library Section", selection: $activeTab) {
                        Text("Songs (\(allTracks.count))").tag(0)
                        Text("Playlists").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    
                    if activeTab == 0 {
                        // Search bar within Library
                        HStack(spacing: 10) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 15))
                                .foregroundColor(Theme.textTertiary)
                            
                            TextField("Search your library...", text: $libraryVM.searchQuery)
                                .font(.system(size: 14))
                                .foregroundColor(Theme.textPrimary)
                            
                            if !libraryVM.searchQuery.isEmpty {
                                Button(action: { libraryVM.searchQuery = "" }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(Theme.textTertiary)
                                }
                            }
                        }
                        .padding(10)
                        .background(Theme.surfaceElevated)
                        .cornerRadius(10)
                        .padding(.horizontal, 20)
                        
                        // Filter Pills & Sort Menu
                        HStack {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(LibraryFilter.allCases, id: \.self) { filter in
                                        Button(action: {
                                            libraryVM.selectedFilter = filter
                                        }) {
                                            Text(filter.rawValue)
                                                .font(.system(size: 12, weight: .semibold))
                                                .foregroundColor(libraryVM.selectedFilter == filter ? .white : Theme.textSecondary)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 6)
                                                .background(
                                                    Capsule().fill(libraryVM.selectedFilter == filter ? Theme.purple : Theme.surfaceElevated)
                                                )
                                                .overlay(
                                                    Capsule().strokeBorder(libraryVM.selectedFilter == filter ? Theme.glow : Theme.surfaceBorder, lineWidth: 1)
                                                )
                                        }
                                        .buttonStyle(ScaleButtonStyle())
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                            
                            // Sort Menu
                            Menu {
                                ForEach(LibrarySortOption.allCases, id: \.self) { option in
                                    Button(action: { libraryVM.sortOption = option }) {
                                        HStack {
                                            Text(option.rawValue)
                                            if libraryVM.sortOption == option {
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                }
                            } label: {
                                Image(systemName: "arrow.up.arrow.down")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(Theme.purple)
                                    .padding(8)
                                    .background(Circle().fill(Theme.surfaceElevated))
                            }
                            .padding(.trailing, 20)
                        }
                        
                        // Status notice if any
                        if let msg = libraryVM.importStatusMessage {
                            Text(msg)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(Theme.purple)
                                .padding(.horizontal, 20)
                        }
                        
                        // Tracks List
                        if displayedTracks.isEmpty {
                            Spacer()
                            EmptyStateView(
                                icon: "music.note",
                                title: "No Songs Found",
                                message: allTracks.isEmpty
                                    ? "Import your audio files from the Files app or download lawful tracks from Search."
                                    : "No tracks match the selected filter or search query.",
                                buttonTitle: allTracks.isEmpty ? "Import from Files" : nil,
                                action: allTracks.isEmpty ? { libraryVM.isFileImporterPresented = true } : nil
                            )
                            Spacer()
                        } else {
                            ScrollView {
                                LazyVStack(spacing: 10) {
                                    ForEach(displayedTracks) { track in
                                        TrackRowView(
                                            track: track,
                                            isCurrentlyPlaying: playerVM.currentTrack?.id == track.id && playerVM.isPlaying,
                                            onPlay: {
                                                playerVM.play(track: track, from: displayedTracks)
                                            },
                                            onFavoriteToggle: {
                                                libraryVM.toggleFavorite(track: track, context: modelContext)
                                            },
                                            onDelete: {
                                                libraryVM.deleteTrack(track: track, context: modelContext)
                                            }
                                        )
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.bottom, 90) // clearance for mini player
                            }
                        }
                    } else {
                        // Playlists Tab
                        ScrollView {
                            PlaylistsView()
                                .padding(.bottom, 90)
                        }
                    }
                }
            }
            .navigationTitle("Library")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        libraryVM.isFileImporterPresented = true
                    }) {
                        Image(systemName: "folder.badge.plus")
                            .foregroundColor(Theme.purple)
                    }
                }
            }
            .fileImporter(
                isPresented: $libraryVM.isFileImporterPresented,
                allowedContentTypes: [.audio, .mp3, .mpeg4Audio, .wav, .aiff],
                allowsMultipleSelection: true
            ) { result in
                libraryVM.handleFileImport(result: result, context: modelContext)
            }
        }
    }
}
