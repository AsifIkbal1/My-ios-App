import SwiftUI
import SwiftData

public struct PlaylistsView: View {
    @Query(sort: \Playlist.updatedAt, order: .reverse)
    private var playlists: [Playlist]
    
    @State private var isCreatePlaylistPresented: Bool = false
    
    public var body: some View {
        VStack(spacing: 16) {
            // New Playlist Action Bar
            HStack {
                Text("Your Playlists")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(Theme.textPrimary)
                
                Spacer()
                
                Button(action: {
                    isCreatePlaylistPresented = true
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "plus")
                        Text("New Playlist")
                    }
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Theme.purple)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(Theme.purple.opacity(0.15)))
                }
            }
            .padding(.horizontal, 20)
            
            if playlists.isEmpty {
                EmptyStateView(
                    icon: "music.note.list",
                    title: "No Playlists",
                    message: "Create your first playlist to organize your offline music library.",
                    buttonTitle: "Create Playlist",
                    action: { isCreatePlaylistPresented = true }
                )
            } else {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(playlists) { playlist in
                        NavigationLink(destination: PlaylistDetailView(playlist: playlist)) {
                            VStack(alignment: .leading, spacing: 10) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(Theme.purpleGradient)
                                        .aspectRatio(1, contentMode: .fit)
                                    
                                    Image(systemName: "music.note.list")
                                        .font(.system(size: 36, weight: .bold))
                                        .foregroundColor(.white)
                                }
                                .purpleGlow(radius: 8, opacity: 0.3)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(playlist.title)
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(Theme.textPrimary)
                                        .lineLimit(1)
                                    
                                    Text("\(playlist.trackCount) songs")
                                        .font(.system(size: 12))
                                        .foregroundColor(Theme.textSecondary)
                                }
                            }
                            .glassCard(cornerRadius: 16)
                        }
                        .buttonStyle(ScaleButtonStyle())
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .sheet(isPresented: $isCreatePlaylistPresented) {
            CreatePlaylistSheet()
        }
    }
}
