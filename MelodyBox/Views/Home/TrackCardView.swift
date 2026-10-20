import SwiftUI

public struct TrackCardView: View {
    public let title: String
    public let artist: String
    public let artworkData: Data?
    public let artworkURL: URL?
    public let licenseType: LicenseType
    public let isDownloaded: Bool
    public let onPlay: () -> Void
    
    public init(
        title: String,
        artist: String,
        artworkData: Data? = nil,
        artworkURL: URL? = nil,
        licenseType: LicenseType = .creativeCommonsBy,
        isDownloaded: Bool = false,
        onPlay: @escaping () -> Void
    ) {
        self.title = title
        self.artist = artist
        self.artworkData = artworkData
        self.artworkURL = artworkURL
        self.licenseType = licenseType
        self.isDownloaded = isDownloaded
        self.onPlay = onPlay
    }
    
    public var body: some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            onPlay()
        }) {
            VStack(alignment: .leading, spacing: 8) {
                // Card Artwork Container
                ZStack(alignment: .bottomTrailing) {
                    Group {
                        if let artworkData = artworkData, let uiImage = UIImage(data: artworkData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } else if let artworkURL = artworkURL {
                            AsyncImage(url: artworkURL) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                case .failure:
                                    artworkPlaceholder
                                case .empty:
                                    ZStack {
                                        Theme.surfaceElevated
                                        ProgressView().tint(Theme.purple)
                                    }
                                @unknown default:
                                    artworkPlaceholder
                                }
                            }
                        } else {
                            artworkPlaceholder
                        }
                    }
                    .frame(width: 140, height: 140)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    
                    // Quick Play Floating Badge
                    Circle()
                        .fill(Theme.purpleGradient)
                        .frame(width: 32, height: 32)
                        .overlay(
                            Image(systemName: "play.fill")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
                                .offset(x: 1)
                        )
                        .purpleGlow(radius: 6, opacity: 0.6)
                        .padding(8)
                    
                    // Offline tag if downloaded
                    if isDownloaded {
                        VStack {
                            HStack {
                                Image(systemName: "arrow.down.circle.fill")
                                    .font(.system(size: 13))
                                    .foregroundColor(Theme.success)
                                    .padding(6)
                                    .background(Circle().fill(Theme.surface.opacity(0.8)))
                                Spacer()
                            }
                            Spacer()
                        }
                        .padding(6)
                    }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(Theme.surfaceBorder, lineWidth: 1)
                )
                
                // Track Info
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Theme.textPrimary)
                        .lineLimit(1)
                    
                    Text(artist)
                        .font(.system(size: 12))
                        .foregroundColor(Theme.textSecondary)
                        .lineLimit(1)
                    
                    LicenseBadgeView(licenseType: licenseType, showDetailsOnTap: false)
                        .padding(.top, 2)
                }
                .frame(width: 140, alignment: .leading)
            }
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    private var artworkPlaceholder: some View {
        ZStack {
            Theme.cardGradient
            Image(systemName: "music.note")
                .font(.system(size: 32))
                .foregroundColor(Theme.purple.opacity(0.8))
        }
    }
}
