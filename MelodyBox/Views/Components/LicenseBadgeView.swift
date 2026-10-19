import SwiftUI

public struct LicenseBadgeView: View {
    public let licenseType: LicenseType
    public let customName: String?
    public var showDetailsOnTap: Bool = true
    
    @State private var isDetailsPresented: Bool = false
    
    public init(licenseType: LicenseType, customName: String? = nil, showDetailsOnTap: Bool = true) {
        self.licenseType = licenseType
        self.customName = customName
        self.showDetailsOnTap = showDetailsOnTap
    }
    
    public var body: some View {
        Button(action: {
            if showDetailsOnTap {
                isDetailsPresented = true
            }
        }) {
            HStack(spacing: 4) {
                Image(systemName: licenseType.badgeIcon)
                    .font(.system(size: 10, weight: .semibold))
                
                Text(licenseType.shortBadge)
                    .font(.system(size: 11, weight: .bold))
            }
            .foregroundColor(licenseType.badgeColor)
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(
                Capsule()
                    .fill(licenseType.badgeColor.opacity(0.15))
            )
            .overlay(
                Capsule()
                    .strokeBorder(licenseType.badgeColor.opacity(0.4), lineWidth: 0.8)
            )
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $isDetailsPresented) {
            LicenseDetailSheet(licenseType: licenseType, customName: customName)
        }
    }
}

public struct LicenseDetailSheet: View {
    public let licenseType: LicenseType
    public let customName: String?
    @Environment(\.dismiss) private var dismiss
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 20) {
                    HStack(spacing: 12) {
                        Image(systemName: licenseType.badgeIcon)
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(licenseType.badgeColor)
                            .padding(12)
                            .background(Circle().fill(licenseType.badgeColor.opacity(0.15)))
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(customName ?? licenseType.displayName)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(Theme.textPrimary)
                            
                            Text(licenseType.isDownloadAllowed ? "Lawful Download Permitted" : "Stream / Preview Only")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(licenseType.badgeColor)
                        }
                    }
                    .padding(.top, 8)
                    
                    Divider().background(Theme.surfaceBorder)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("License Details")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Theme.textSecondary)
                        
                        Text(licenseType.legalDescription)
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(Theme.textPrimary)
                            .lineSpacing(4)
                    }
                    .glassCard()
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Legal Guarantee")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Theme.textSecondary)
                        
                        Text("MelodyBox respects intellectual property and content creator rights. We never bypass DRM or scrape restricted services. All media discovered or downloaded in this catalog is verified under authorized Creative Commons, Public Domain, or lawful distribution terms.")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(Theme.textSecondary)
                            .lineSpacing(3)
                    }
                    .glassCard()
                    
                    Spacer()
                }
                .padding(20)
            }
            .navigationTitle("Audio Licensing")
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
