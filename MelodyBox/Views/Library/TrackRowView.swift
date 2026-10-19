import SwiftUI
import SwiftData

public struct TrackRowView: View {
    public let track: Track
    public let isCurrentlyPlaying: Bool
    public let onPlay: () -> Void
    public let onFavoriteToggle: () -> Void
    public let onDelete: () -> Void
    
    @Environment(\.modelContext) private var modelContext
    @State private var isAddToPlaylistPresented: Bool = false
    
    @Query(sort: \Playlist.updatedAt, order: .reverse)
    private var allPlaylists: [Playlist]
    
    public var body: some View {
        HStack(spacing: 12) {
            // Artwork / Play Button
            Button(action: onPlay) {
                ZStack {
                    if let artworkData = track.artworkData, let uiImage = UIImage(data: artworkData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Theme.surfaceElevated)
                            .overlay(
                                Image(systemName: isCurrentlyPlaying ? "waveform" : "music.note")
                                    .font(.system(size: 16))
                                    .foregroundColor(isCurrentlyPlaying ? Theme.purple : Theme.textTertiary)
                            )
                    }
                }
                .frame(width: 46, height: 46)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(isCurrentlyPlaying ? Theme.purple : Theme.surfaceBorder, lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
            
            // Track Info
            VStack(alignment: .leading, spacing: 3) {
                Text(track.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(isCurrentlyPlaying ? Theme.purple : Theme.textPrimary)
                    .lineLimit(1)
                
                HStack(spacing: 6) {
                    Text(track.artist)
                        .font(.system(size: 13))
                        .foregroundColor(Theme.textSecondary)
                        .lineLimit(1)
                    
                    Text("•")
                        .foregroundColor(Theme.textTertiary)
                    
                    Text(track.formattedDuration)
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(Theme.textTertiary)
                }
                
                HStack(spacing: 6) {
                    LicenseBadgeView(licenseType: track.licenseType, customName: track.licenseName, showDetailsOnTap: true)
                    
                    if track.isDownloaded {
                        HStack(spacing: 3) {
                            Image(systemName: "arrow.down.circle.fill")
                                .font(.system(size: 10))
                            Text("Offline")
                                .font(.system(size: 10, weight: .bold))
                        }
                        .foregroundColor(Theme.success)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(Theme.success.opacity(0.12)))
                    }
                }
                .padding(.top, 2)
            }
            
            Spacer()
            
            // Favorite Button
            Button(action: onFavoriteToggle) {
                Image(systemName: track.isFavorite ? "heart.fill" : "heart")
                    .font(.system(size: 18))
                    .foregroundColor(track.isFavorite ? Theme.accent : Theme.textTertiary)
                    .frame(width: 36, height: 36)
            }
            .buttonStyle(.plain)
            
            // Context Menu Button
            Menu {
                Button(action: onPlay) {
                    Label("Play", systemImage: "play.fill")
                }
                
                Button(action: {
                    AudioPlayerService.shared.playNext(track)
                }) {
                    Label("Play Next", systemImage: "text.line.first.and.arrowtriangle.forward")
                }
                
                Button(action: {
                    AudioPlayerService.shared.addToQueue(track)
                }) {
                    Label("Add to Queue", systemImage: "text.badge.plus")
                }
                
                Button(action: {
                    isAddToPlaylistPresented = true
                }) {
                    Label("Add to Playlist...", systemImage: "music.note.list")
                }
                
                Button(action: onFavoriteToggle) {
                    Label(track.isFavorite ? "Remove from Favorites" : "Add to Favorites", systemImage: track.isFavorite ? "heart.slash" : "heart")
                }
                
                Divider()
                
                Button(role: .destructive, action: onDelete) {
                    Label("Delete Track", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 16))
                    .foregroundColor(Theme.textTertiary)
                    .frame(width: 32, height: 36)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 14)
        .glassCard(cornerRadius: 12)
        .sheet(isPresented: $isAddToPlaylistPresented) {
            AddToPlaylistSheet(track: track)
        }
    }
}

public struct AddToPlaylistSheet: View {
    public let track: Track
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \Playlist.updatedAt, order: .reverse)
    private var playlists: [Playlist]
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                
                if playlists.isEmpty {
                    EmptyStateView(
                        icon: "music.note.list",
                        title: "No Playlists Yet",
                        message: "Create a playlist first in your Library."
                    )
                } else {
                    List {
                        ForEach(playlists) { playlist in
                            Button(action: {
                                if !playlist.tracks.contains(where: { $0.id == track.id }) {
                                    playlist.tracks.append(track)
                                    playlist.updatedAt = Date()
                                    try? modelContext.save()
                                }
                                dismiss()
                            }) {
                                HStack(spacing: 12) {
                                    Image(systemName: "music.note.list")
                                        .foregroundColor(Theme.purple)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(playlist.title)
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundColor(Theme.textPrimary)
                                        Text("\(playlist.trackCount) tracks")
                                            .font(.system(size: 12))
                                            .foregroundColor(Theme.textSecondary)
                                    }
                                    
                                    Spacer()
                                    
                                    if playlist.tracks.contains(where: { $0.id == track.id }) {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(Theme.purple)
                                    }
                                }
                            }
                            .listRowBackground(Theme.surface.opacity(0.7))
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Add to Playlist")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(Theme.purple)
                }
            }
        }
        .presentationDetents([.medium])
    }
}
