import SwiftUI
import SwiftData

public struct CatalogTrackRowView: View {
    public let track: CatalogTrack
    public let onPlay: () -> Void
    public let onDownload: () -> Void
    
    @Bindable var playerVM: PlayerViewModel = .shared
    
    private var isCurrentlyPlaying: Bool {
        playerVM.currentTrack?.id == track.id && playerVM.isPlaying
    }
    
    public var body: some View {
        HStack(spacing: 12) {
            // Artwork / Play Button
            Button(action: onPlay) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Theme.surfaceElevated)
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: isCurrentlyPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Theme.purple)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(Theme.surfaceBorder, lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
            
            // Metadata
            VStack(alignment: .leading, spacing: 3) {
                Text(track.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(isCurrentlyPlaying ? Theme.purple : Theme.textPrimary)
                    .lineLimit(1)
                
                Text("\(track.artist) • \(track.duration.formattedDuration)")
                    .font(.system(size: 12))
                    .foregroundColor(Theme.textSecondary)
                    .lineLimit(1)
                
                HStack(spacing: 6) {
                    LicenseBadgeView(licenseType: track.licenseType, customName: track.licenseName)
                    
                    Text(track.genre)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(Theme.textTertiary)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(Theme.surfaceElevated))
                }
                .padding(.top, 2)
            }
            
            Spacer()
            
            // Download Action
            if track.isDownloadAllowed {
                Button(action: {
                    let impact = UIImpactFeedbackGenerator(style: .medium)
                    impact.impactOccurred()
                    onDownload()
                }) {
                    Image(systemName: "arrow.down.circle")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(Theme.purple)
                        .frame(width: 40, height: 40)
                }
                .buttonStyle(.plain)
            } else {
                Text("Stream")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(Theme.warning)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Theme.warning.opacity(0.15)))
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 14)
        .glassCard(cornerRadius: 12)
    }
}
