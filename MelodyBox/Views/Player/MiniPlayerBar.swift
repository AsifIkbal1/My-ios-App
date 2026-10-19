import SwiftUI

public struct MiniPlayerBar: View {
    @Bindable var playerVM: PlayerViewModel = .shared
    
    public var body: some View {
        if let track = playerVM.currentTrack {
            VStack(spacing: 0) {
                // Micro Progress Line
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.white.opacity(0.1))
                            .frame(height: 2)
                        
                        Rectangle()
                            .fill(Theme.purpleGradient)
                            .frame(width: geo.size.width * CGFloat(playerVM.progress), height: 2)
                            .purpleGlow(radius: 4, opacity: 0.8)
                    }
                }
                .frame(height: 2)
                
                // Mini Player Content
                HStack(spacing: 12) {
                    // Artwork Thumbnail
                    ZStack {
                        if let artworkData = track.artworkData, let uiImage = UIImage(data: artworkData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } else {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Theme.surfaceElevated)
                                .overlay(
                                    Image(systemName: "music.note")
                                        .font(.system(size: 18))
                                        .foregroundColor(Theme.purple)
                                )
                        }
                    }
                    .frame(width: 44, height: 44)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(Theme.purple.opacity(0.4), lineWidth: 1)
                    )
                    
                    // Title & Artist
                    VStack(alignment: .leading, spacing: 3) {
                        Text(track.title)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Theme.textPrimary)
                            .lineLimit(1)
                        
                        Text(track.artist)
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(Theme.textSecondary)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    // Play/Pause Button
                    Button(action: {
                        let impact = UIImpactFeedbackGenerator(style: .light)
                        impact.impactOccurred()
                        playerVM.togglePlayPause()
                    }) {
                        Image(systemName: playerVM.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Theme.textPrimary)
                            .frame(width: 36, height: 36)
                            .background(Circle().fill(Theme.purple.opacity(0.2)))
                    }
                    
                    // Next Track Button
                    Button(action: {
                        let impact = UIImpactFeedbackGenerator(style: .light)
                        impact.impactOccurred()
                        playerVM.nextTrack()
                    }) {
                        Image(systemName: "forward.fill")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Theme.textSecondary)
                            .frame(width: 36, height: 36)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Theme.surfaceElevated.opacity(0.96)
                        .background(.ultraThinMaterial)
                )
            }
            .contentShape(Rectangle())
            .onTapGesture {
                playerVM.isNowPlayingExpanded = true
            }
            .gesture(
                DragGesture(minimumDistance: 25)
                    .onEnded { value in
                        if value.translation.width < -30 {
                            // Swipe left -> Next
                            playerVM.nextTrack()
                        } else if value.translation.width > 30 {
                            // Swipe right -> Previous
                            playerVM.previousTrack()
                        }
                    }
            )
            .sheet(isPresented: $playerVM.isNowPlayingExpanded) {
                NowPlayingView()
            }
        }
    }
}
