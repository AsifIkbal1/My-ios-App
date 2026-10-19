import SwiftUI

public struct FeaturedHeroView: View {
    public let track: CatalogTrack
    public let onPlay: () -> Void
    public let onDownload: () -> Void
    
    public init(track: CatalogTrack, onPlay: @escaping () -> Void, onDownload: @escaping () -> Void) {
        self.track = track
        self.onPlay = onPlay
        self.onDownload = onDownload
    }
    
    public var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Background Artwork / Gradient
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "2E1065"), Color(hex: "170C2A")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            // Subtle Radial Glow
            Circle()
                .fill(Theme.purple.opacity(0.35))
                .frame(width: 220, height: 220)
                .blur(radius: 50)
                .offset(x: 100, y: -40)
            
            VStack(alignment: .leading, spacing: 14) {
                // Top Tag
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 11, weight: .bold))
                        Text("FEATURED LAWFUL MASTERPIECE")
                            .font(.system(size: 10, weight: .bold))
                            .tracking(1)
                    }
                    .foregroundColor(Theme.glow)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Capsule().fill(Theme.purple.opacity(0.2)))
                    .overlay(Capsule().strokeBorder(Theme.purple.opacity(0.4), lineWidth: 0.8))
                    
                    Spacer()
                    
                    LicenseBadgeView(licenseType: track.licenseType)
                }
                
                Spacer()
                
                // Track Details
                VStack(alignment: .leading, spacing: 4) {
                    Text(track.title)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(Theme.textPrimary)
                        .lineLimit(1)
                    
                    Text("\(track.artist) • \(track.genre)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Theme.textSecondary)
                }
                
                // Action Buttons
                HStack(spacing: 12) {
                    GradientButton(title: "Play Now", icon: "play.fill", action: onPlay)
                    
                    if track.isDownloadAllowed {
                        Button(action: onDownload) {
                            HStack(spacing: 6) {
                                Image(systemName: "arrow.down")
                                    .font(.system(size: 14, weight: .bold))
                                Text("Download")
                                    .font(.system(size: 14, weight: .semibold))
                            }
                            .foregroundColor(Theme.textPrimary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                Capsule().fill(Theme.surfaceElevated.opacity(0.9))
                            )
                            .overlay(
                                Capsule().strokeBorder(Theme.surfaceBorder, lineWidth: 1)
                            )
                        }
                        .buttonStyle(ScaleButtonStyle())
                    }
                }
            }
            .padding(20)
        }
        .frame(height: 220)
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(Theme.purple.opacity(0.35), lineWidth: 1)
        )
        .shadow(color: Theme.purple.opacity(0.25), radius: 16, x: 0, y: 8)
    }
}
