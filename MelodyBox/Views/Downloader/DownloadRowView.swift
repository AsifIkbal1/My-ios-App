import SwiftUI
import SwiftData

public struct DownloadRowView: View {
    public let item: DownloadItem
    public let progressState: BackgroundDownloadManager.DownloadProgressState?
    public let onPause: () -> Void
    public let onResume: () -> Void
    public let onRetry: () -> Void
    public let onDelete: () -> Void
    
    private var effectiveProgress: Double {
        progressState?.progress ?? item.progress
    }
    
    private var effectiveStatus: DownloadStatus {
        progressState?.status ?? item.status
    }
    
    public var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 12) {
                // Status Icon Indicator
                ZStack {
                    Circle()
                        .fill(statusColor.opacity(0.15))
                        .frame(width: 42, height: 42)
                    
                    Image(systemName: statusIcon)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(statusColor)
                }
                
                // Track Info
                VStack(alignment: .leading, spacing: 3) {
                    Text(item.title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Theme.textPrimary)
                        .lineLimit(1)
                    
                    Text("\(item.artist) • \(effectiveStatus.label)")
                        .font(.system(size: 12))
                        .foregroundColor(Theme.textSecondary)
                        .lineLimit(1)
                    
                    LicenseBadgeView(licenseType: item.licenseType, customName: item.licenseName, showDetailsOnTap: true)
                        .padding(.top, 2)
                }
                
                Spacer()
                
                // Action Buttons
                HStack(spacing: 8) {
                    switch effectiveStatus {
                    case .downloading:
                        Button(action: onPause) {
                            Image(systemName: "pause.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(Theme.purple)
                        }
                    case .paused:
                        Button(action: onResume) {
                            Image(systemName: "play.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(Theme.purple)
                        }
                    case .failed:
                        Button(action: onRetry) {
                            Image(systemName: "arrow.clockwise.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(Theme.warning)
                        }
                    case .completed:
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(Theme.success)
                    case .pending, .cancelled:
                        EmptyView()
                    }
                    
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .font(.system(size: 16))
                            .foregroundColor(Theme.textTertiary)
                            .padding(6)
                    }
                }
            }
            
            // Progress Bar (if in progress or paused)
            if effectiveStatus == .downloading || effectiveStatus == .paused {
                VStack(spacing: 4) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.white.opacity(0.1))
                                .frame(height: 4)
                            
                            Capsule()
                                .fill(Theme.purpleGradient)
                                .frame(width: geo.size.width * CGFloat(effectiveProgress), height: 4)
                                .purpleGlow(radius: 4, opacity: 0.5)
                        }
                    }
                    .frame(height: 4)
                    
                    HStack {
                        Text(item.formattedBytesStatus)
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(Theme.textTertiary)
                        
                        Spacer()
                        
                        Text(item.formattedProgress)
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(Theme.purple)
                    }
                }
            }
            
            if let error = item.errorMessage, effectiveStatus == .failed {
                Text(error)
                    .font(.system(size: 11))
                    .foregroundColor(Theme.error)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(14)
        .glassCard(cornerRadius: 14)
    }
    
    private var statusColor: Color {
        switch effectiveStatus {
        case .downloading: return Theme.purple
        case .completed: return Theme.success
        case .paused: return Theme.warning
        case .failed: return Theme.error
        case .pending, .cancelled: return Theme.textTertiary
        }
    }
    
    private var statusIcon: String {
        switch effectiveStatus {
        case .downloading: return "arrow.down"
        case .completed: return "checkmark"
        case .paused: return "pause.fill"
        case .failed: return "exclamationmark.triangle.fill"
        case .pending: return "clock.fill"
        case .cancelled: return "xmark"
        }
    }
}
