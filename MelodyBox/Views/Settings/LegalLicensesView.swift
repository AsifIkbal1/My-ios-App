import SwiftUI

public struct LegalLicensesView: View {
    @Environment(\.dismiss) private var dismiss
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Theme.backgroundGradient.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Lawful Architecture Guarantee
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundColor(Theme.success)
                                    .font(.system(size: 20))
                                Text("MelodyBox Lawful Standard")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(Theme.textPrimary)
                            }
                            
                            Text("MelodyBox is architected strictly as an offline audio player and lawful content discovery app. It does NOT bypass DRM, decrypt restricted media, or scrape unauthorized streaming platforms (such as YouTube, Spotify, or Apple Music).")
                                .font(.system(size: 13))
                                .foregroundColor(Theme.textSecondary)
                                .lineSpacing(3)
                        }
                        .padding(16)
                        .glassCard(cornerRadius: 16)
                        
                        // Creative Commons Licenses
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Supported Open Licenses")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(Theme.textPrimary)
                            
                            ForEach(LicenseType.allCases, id: \.self) { license in
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        LicenseBadgeView(licenseType: license, showDetailsOnTap: false)
                                        Spacer()
                                        Text(license.isDownloadAllowed ? "Download Permitted" : "Stream Only")
                                            .font(.system(size: 11, weight: .semibold))
                                            .foregroundColor(license.badgeColor)
                                    }
                                    
                                    Text(license.legalDescription)
                                        .font(.system(size: 12))
                                        .foregroundColor(Theme.textTertiary)
                                        .lineSpacing(2)
                                }
                                .padding(12)
                                .background(Theme.surfaceElevated.opacity(0.6))
                                .cornerRadius(10)
                            }
                        }
                        .padding(16)
                        .glassCard(cornerRadius: 16)
                        
                        // Music Providers Attribution
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Open Catalog Providers & Attribution")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(Theme.textPrimary)
                            
                            Text("• **Musopen / Wikimedia Commons**: Classical performances released into the Public Domain and Creative Commons.\n• **Jamendo Music**: Original indie works licensed under Creative Commons by artists worldwide.\n• **Free Music Archive (FMA)**: Curated open music library fostering legal music sharing.")
                                .font(.system(size: 13))
                                .foregroundColor(Theme.textSecondary)
                                .lineSpacing(4)
                        }
                        .padding(16)
                        .glassCard(cornerRadius: 16)
                        
                        // Privacy Guarantee
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 8) {
                                Image(systemName: "hand.raised.fill")
                                    .foregroundColor(Theme.purple)
                                Text("Privacy-First Operation")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(Theme.textPrimary)
                            }
                            
                            Text("MelodyBox contains zero telemetry, zero advertising trackers, and zero user profiling. Your listening history, playlists, and audio files reside strictly on your local iPhone storage.")
                                .font(.system(size: 13))
                                .foregroundColor(Theme.textSecondary)
                                .lineSpacing(3)
                        }
                        .padding(16)
                        .glassCard(cornerRadius: 16)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Legal & Licenses")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(Theme.purple)
                        .fontWeight(.semibold)
                }
            }
        }
    }
}
