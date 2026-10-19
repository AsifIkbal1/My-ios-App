import SwiftUI
import SwiftData

public struct SearchView: View {
    @State private var searchVM = SearchViewModel()
    @Bindable var playerVM: PlayerViewModel = .shared
    @Environment(\.modelContext) private var modelContext
    
    @State private var downloadQueuedNotice: String? = nil
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Theme.backgroundGradient.ignoresSafeArea()
                
                VStack(spacing: 16) {
                    // Search Bar
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Theme.textTertiary)
                        
                        TextField("Search lawful tracks, artists, genres...", text: $searchVM.query)
                            .font(.system(size: 15))
                            .foregroundColor(Theme.textPrimary)
                            .tint(Theme.purple)
                            .onChange(of: searchVM.query) { _, _ in
                                searchVM.onQueryChanged()
                            }
                        
                        if !searchVM.query.isEmpty {
                            Button(action: {
                                searchVM.query = ""
                                searchVM.onQueryChanged()
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(Theme.textTertiary)
                            }
                        }
                    }
                    .padding(12)
                    .background(Theme.surfaceElevated.opacity(0.9))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(Theme.surfaceBorder, lineWidth: 1)
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    
                    // Provider Selector Bar
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(Array(searchVM.providers.enumerated()), id: \.offset) { index, provider in
                                Button(action: {
                                    searchVM.selectedProviderIndex = index
                                }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: provider.providerIcon)
                                            .font(.system(size: 12))
                                        Text(provider.providerName)
                                            .font(.system(size: 13, weight: .semibold))
                                    }
                                    .foregroundColor(searchVM.selectedProviderIndex == index ? .white : Theme.textSecondary)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(
                                        Capsule().fill(
                                            searchVM.selectedProviderIndex == index ? Theme.purple : Theme.surfaceElevated
                                        )
                                    )
                                    .overlay(
                                        Capsule().strokeBorder(
                                            searchVM.selectedProviderIndex == index ? Theme.glow : Theme.surfaceBorder,
                                            lineWidth: 1
                                        )
                                    )
                                }
                                .buttonStyle(ScaleButtonStyle())
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Genre Filter Pills
                    if !searchVM.genres.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(searchVM.genres) { genre in
                                    Button(action: {
                                        searchVM.selectGenre(genre)
                                    }) {
                                        HStack(spacing: 4) {
                                            Image(systemName: genre.icon)
                                                .font(.system(size: 11))
                                            Text(genre.name)
                                                .font(.system(size: 12, weight: .medium))
                                        }
                                        .foregroundColor(searchVM.selectedGenre?.id == genre.id ? Theme.purple : Theme.textTertiary)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(
                                            Capsule().fill(searchVM.selectedGenre?.id == genre.id ? Theme.purple.opacity(0.15) : Color.clear)
                                        )
                                        .overlay(
                                            Capsule().strokeBorder(searchVM.selectedGenre?.id == genre.id ? Theme.purple.opacity(0.4) : Color.white.opacity(0.08), lineWidth: 0.8)
                                        )
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    
                    // Notice Toast
                    if let notice = downloadQueuedNotice {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(Theme.success)
                            Text(notice)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(Theme.textPrimary)
                            Spacer()
                        }
                        .padding(10)
                        .background(Theme.surfaceElevated)
                        .cornerRadius(10)
                        .padding(.horizontal, 20)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    
                    // Results List
                    if searchVM.isSearching {
                        Spacer()
                        ProgressView()
                            .tint(Theme.purple)
                            .scaleEffect(1.3)
                        Spacer()
                    } else if searchVM.searchResults.isEmpty {
                        Spacer()
                        EmptyStateView(
                            icon: "waveform.badge.magnifyingglass",
                            title: "No Tracks Found",
                            message: "Try searching for a different track title, artist, or select another licensed music provider."
                        )
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 10) {
                                ForEach(searchVM.searchResults) { track in
                                    CatalogTrackRowView(
                                        track: track,
                                        onPlay: {
                                            searchVM.previewTrack(track)
                                        },
                                        onDownload: {
                                            searchVM.queueDownload(for: track, context: modelContext)
                                            withAnimation {
                                                downloadQueuedNotice = "Queued download for \(track.title)"
                                            }
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                                withAnimation {
                                                    downloadQueuedNotice = nil
                                                }
                                            }
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 90) // mini player clearance
                        }
                    }
                }
            }
            .navigationTitle("Discover Music")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
