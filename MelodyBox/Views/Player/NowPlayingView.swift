import SwiftUI
import SwiftData

public struct NowPlayingView: View {
    @Bindable var playerVM: PlayerViewModel = .shared
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var isScrubbing: Bool = false
    @State private var scrubProgress: Double = 0.0
    @State private var artworkRotation: Double = 0.0
    
    public var body: some View {
        ZStack {
            // Ambient Dark Purple Gradient Background
            Theme.backgroundGradient
                .ignoresSafeArea()
            
            if let track = playerVM.currentTrack {
                VStack(spacing: 0) {
                    // Top Bar (Grabber, Dismiss, Queue)
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.down")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(Theme.textSecondary)
                                .frame(width: 44, height: 44)
                        }
                        
                        Spacer()
                        
                        VStack(spacing: 2) {
                            Text("PLAYING FROM")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(Theme.textTertiary)
                                .tracking(1)
                            
                            Text(track.album.isEmpty ? "MelodyBox" : track.album)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(Theme.textSecondary)
                                .lineLimit(1)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            playerVM.isQueueSheetPresented = true
                        }) {
                            Image(systemName: "list.bullet")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(Theme.textSecondary)
                                .frame(width: 44, height: 44)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    
                    Spacer()
                    
                    // Large Animated Album Artwork
                    ZStack {
                        // Ambient Artwork Glow
                        Circle()
                            .fill(Theme.purple.opacity(0.3))
                            .frame(width: 260, height: 260)
                            .blur(radius: 40)
                        
                        // Artwork Image
                        Group {
                            if let artworkData = track.artworkData, let uiImage = UIImage(data: artworkData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } else if let artworkURLStr = track.remoteArtworkURLString, let artworkURL = URL(string: artworkURLStr) {
                                AsyncImage(url: artworkURL) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                    default:
                                        nowPlayingPlaceholder(for: track)
                                    }
                                }
                            } else {
                                nowPlayingPlaceholder(for: track)
                            }
                        }
                        .frame(width: 280, height: 280)
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .strokeBorder(LinearGradient(
                                    colors: [Theme.purple.opacity(0.6), Theme.accent.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ), lineWidth: 1.5)
                        )
                        .shadow(color: Color.black.opacity(0.6), radius: 24, x: 0, y: 16)
                        .scaleEffect(playerVM.isPlaying ? 1.02 : 0.96)
                        .animation(.easeInOut(duration: 0.35), value: playerVM.isPlaying)
                    }
                    .padding(.vertical, 20)
                    
                    // Waveform Audio Spectrum
                    WaveformVisualizerView(isPlaying: playerVM.isPlaying, barCount: 30)
                        .padding(.vertical, 8)
                    
                    Spacer()
                    
                    // Track Title, Artist, & Lawful License Badge
                    VStack(spacing: 8) {
                        HStack(alignment: .center) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(track.title)
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(Theme.textPrimary)
                                    .lineLimit(1)
                                
                                Text(track.artist)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(Theme.textSecondary)
                                    .lineLimit(1)
                            }
                            
                            Spacer()
                            
                            // Favorite Button
                            Button(action: {
                                let impact = UIImpactFeedbackGenerator(style: .light)
                                impact.impactOccurred()
                                track.isFavorite.toggle()
                                try? modelContext.save()
                            }) {
                                Image(systemName: track.isFavorite ? "heart.fill" : "heart")
                                    .font(.system(size: 22, weight: .semibold))
                                    .foregroundColor(track.isFavorite ? Theme.accent : Theme.textSecondary)
                                    .frame(width: 44, height: 44)
                            }
                        }
                        
                        // License Pill & Info
                        HStack {
                            LicenseBadgeView(licenseType: track.licenseType, customName: track.licenseName)
                            
                            if track.isDownloaded {
                                HStack(spacing: 4) {
                                    Image(systemName: "arrow.down.circle.fill")
                                        .font(.system(size: 11))
                                    Text("Offline")
                                        .font(.system(size: 11, weight: .bold))
                                }
                                .foregroundColor(Theme.success)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 3)
                                .background(Capsule().fill(Theme.success.opacity(0.15)))
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                playerVM.isTrackInfoPresented = true
                            }) {
                                Image(systemName: "info.circle")
                                    .font(.system(size: 16))
                                    .foregroundColor(Theme.textTertiary)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    // Custom Seek Slider
                    VStack(spacing: 6) {
                        CustomSlider(
                            value: Binding(
                                get: { isScrubbing ? scrubProgress : playerVM.progress },
                                set: { scrubProgress = $0 }
                            ),
                            onEditingChanged: { editing in
                                isScrubbing = editing
                                playerVM.audioService.isSeeking = editing
                                if !editing {
                                    playerVM.seek(to: scrubProgress)
                                }
                            }
                        )
                        
                        HStack {
                            Text(isScrubbing ? (scrubProgress * playerVM.duration).formattedDuration : playerVM.formattedCurrentTime)
                                .font(.system(size: 12, weight: .medium, design: .monospaced))
                                .foregroundColor(Theme.textTertiary)
                            
                            Spacer()
                            
                            Text(playerVM.formattedRemainingTime)
                                .font(.system(size: 12, weight: .medium, design: .monospaced))
                                .foregroundColor(Theme.textTertiary)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    
                    // Main Playback Controls
                    HStack(spacing: 20) {
                        // Shuffle Button
                        Button(action: {
                            playerVM.toggleShuffle()
                        }) {
                            Image(systemName: "shuffle")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(playerVM.audioService.isShuffled ? Theme.purple : Theme.textTertiary)
                                .frame(width: 36, height: 36)
                        }
                        
                        Spacer()
                        
                        // Previous Track
                        Button(action: {
                            let impact = UIImpactFeedbackGenerator(style: .medium)
                            impact.impactOccurred()
                            playerVM.previousTrack()
                        }) {
                            Image(systemName: "backward.fill")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(Theme.textPrimary)
                                .frame(width: 44, height: 44)
                        }
                        
                        // Skip Backward 15s
                        Button(action: {
                            playerVM.skipBackward()
                        }) {
                            Image(systemName: "gobackward.15")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(Theme.textSecondary)
                        }
                        
                        // Play / Pause Hero Button
                        Button(action: {
                            let impact = UIImpactFeedbackGenerator(style: .heavy)
                            impact.impactOccurred()
                            playerVM.togglePlayPause()
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Theme.purpleGradient)
                                    .frame(width: 72, height: 72)
                                    .purpleGlow(radius: 16, opacity: 0.7)
                                
                                Image(systemName: playerVM.isPlaying ? "pause.fill" : "play.fill")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.white)
                                    .offset(x: playerVM.isPlaying ? 0 : 2)
                            }
                        }
                        .scaleEffect(playerVM.isPlaying ? 1.0 : 0.97)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: playerVM.isPlaying)
                        
                        // Skip Forward 15s
                        Button(action: {
                            playerVM.skipForward()
                        }) {
                            Image(systemName: "goforward.15")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(Theme.textSecondary)
                        }
                        
                        // Next Track
                        Button(action: {
                            let impact = UIImpactFeedbackGenerator(style: .medium)
                            impact.impactOccurred()
                            playerVM.nextTrack()
                        }) {
                            Image(systemName: "forward.fill")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(Theme.textPrimary)
                                .frame(width: 44, height: 44)
                        }
                        
                        Spacer()
                        
                        // Repeat Mode Button
                        Button(action: {
                            playerVM.cycleRepeatMode()
                        }) {
                            Image(systemName: playerVM.audioService.repeatMode.iconName)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(playerVM.audioService.repeatMode != .off ? Theme.purple : Theme.textTertiary)
                                .frame(width: 36, height: 36)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    
                    Spacer()
                }
            }
        }
        .sheet(isPresented: $playerVM.isQueueSheetPresented) {
            UpNextQueueSheet()
        }
        .sheet(isPresented: $playerVM.isTrackInfoPresented) {
            if let track = playerVM.currentTrack {
                TrackAttributionSheet(track: track)
            }
        }
    }
    
    @ViewBuilder
    private func nowPlayingPlaceholder(for track: Track) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(Theme.cardGradient)
            
            VStack(spacing: 12) {
                Image(systemName: "waveform.circle.fill")
                    .font(.system(size: 72))
                    .foregroundStyle(Theme.purpleGradient)
                
                Text(track.genreOrFormat)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Theme.textSecondary)
                    .tracking(1.5)
            }
        }
    }
}

public struct TrackAttributionSheet: View {
    public let track: Track
    @Environment(\.dismiss) private var dismiss
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(track.title)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Theme.textPrimary)
                        Text(track.artist)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Theme.textSecondary)
                    }
                    
                    Divider().background(Theme.surfaceBorder)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("License")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Theme.textTertiary)
                        Text(track.licenseName)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Theme.purple)
                    }
                    .glassCard()
                    
                    if let attribution = track.attributionText, !attribution.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Attribution / Creator Credit")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(Theme.textTertiary)
                            Text(attribution)
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(Theme.textPrimary)
                        }
                        .glassCard()
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("File Details")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Theme.textTertiary)
                        HStack {
                            Text("Duration:")
                            Spacer()
                            Text(track.formattedDuration)
                        }
                        .font(.system(size: 14))
                        .foregroundColor(Theme.textSecondary)
                        
                        if track.fileSize > 0 {
                            HStack {
                                Text("Storage Size:")
                                Spacer()
                                Text(track.formattedFileSize)
                            }
                            .font(.system(size: 14))
                            .foregroundColor(Theme.textSecondary)
                        }
                    }
                    .glassCard()
                    
                    Spacer()
                }
                .padding(20)
            }
            .navigationTitle("Track Information")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(Theme.purple)
                        .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.medium])
    }
}
