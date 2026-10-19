import SwiftUI
import SwiftData

public struct PlaylistDetailView: View {
    @Bindable var playlist: Playlist
    @Bindable var playerVM: PlayerViewModel = .shared
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var isDeleteAlertPresented: Bool = false
    
    public var body: some View {
        ZStack {
            Theme.backgroundGradient.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header Info
                VStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Theme.purpleGradient)
                            .frame(width: 100, height: 100)
                            .purpleGlow(radius: 12, opacity: 0.4)
                        
                        Image(systemName: "music.note.list")
                            .font(.system(size: 44, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.top, 16)
                    
                    Text(playlist.title)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(Theme.textPrimary)
                    
                    if !playlist.playlistDescription.isEmpty {
                        Text(playlist.playlistDescription)
                            .font(.system(size: 14))
                            .foregroundColor(Theme.textSecondary)
                    }
                    
                    Text("\(playlist.trackCount) songs • \(playlist.formattedDuration)")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Theme.textTertiary)
                    
                    // Action Buttons (Play All & Shuffle)
                    if !playlist.tracks.isEmpty {
                        HStack(spacing: 16) {
                            GradientButton(title: "Play All", icon: "play.fill") {
                                if let first = playlist.tracks.first {
                                    playerVM.play(track: first, from: playlist.tracks)
                                }
                            }
                            
                            Button(action: {
                                var shuffled = playlist.tracks
                                shuffled.shuffle()
                                if let first = shuffled.first {
                                    playerVM.play(track: first, from: shuffled)
                                }
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "shuffle")
                                        .font(.system(size: 14, weight: .semibold))
                                    Text("Shuffle")
                                        .font(.system(size: 14, weight: .semibold))
                                }
                                .foregroundColor(Theme.textPrimary)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(Capsule().fill(Theme.surfaceElevated))
                                .overlay(Capsule().strokeBorder(Theme.surfaceBorder, lineWidth: 1))
                            }
                            .buttonStyle(ScaleButtonStyle())
                        }
                        .padding(.top, 8)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
                
                Divider().background(Theme.surfaceBorder)
                
                // Track List
                if playlist.tracks.isEmpty {
                    Spacer()
                    EmptyStateView(
                        icon: "music.note",
                        title: "No Songs in this Playlist",
                        message: "Add songs by tapping the '...' menu on any track in your Library or Search."
                    )
                    Spacer()
                } else {
                    List {
                        ForEach(Array(playlist.tracks.enumerated()), id: \.element.id) { index, track in
                            HStack(spacing: 12) {
                                Text("\(index + 1)")
                                    .font(.system(size: 12, weight: .semibold, design: .monospaced))
                                    .foregroundColor(Theme.textTertiary)
                                    .frame(width: 20)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(track.title)
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(Theme.textPrimary)
                                        .lineLimit(1)
                                    Text(track.artist)
                                        .font(.system(size: 12))
                                        .foregroundColor(Theme.textSecondary)
                                        .lineLimit(1)
                                }
                                
                                Spacer()
                                
                                Text(track.formattedDuration)
                                    .font(.system(size: 12, design: .monospaced))
                                    .foregroundColor(Theme.textTertiary)
                            }
                            .listRowBackground(Theme.surface.opacity(0.6))
                            .listRowSeparatorTint(Theme.surfaceBorder)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                playerVM.play(track: track, from: playlist.tracks)
                            }
                        }
                        .onDelete { offsets in
                            playlist.tracks.remove(atOffsets: offsets)
                            playlist.updatedAt = Date()
                            try? modelContext.save()
                        }
                        .onMove { source, destination in
                            playlist.tracks.move(fromOffsets: source, toOffset: destination)
                            playlist.updatedAt = Date()
                            try? modelContext.save()
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .padding(.bottom, 80) // clearance for mini player
                }
            }
        }
        .navigationTitle(playlist.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    EditButton()
                    
                    Button(role: .destructive, action: {
                        isDeleteAlertPresented = true
                    }) {
                        Label("Delete Playlist", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(Theme.purple)
                }
            }
        }
        .alert("Delete Playlist?", isPresented: $isDeleteAlertPresented) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                modelContext.delete(playlist)
                try? modelContext.save()
                dismiss()
            }
        } message: {
            Text("Are you sure you want to delete '\(playlist.title)'? Audio tracks will remain in your library.")
        }
    }
}
