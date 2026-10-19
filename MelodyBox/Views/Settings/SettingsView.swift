import SwiftUI
import SwiftData

public struct SettingsView: View {
    @State private var settingsVM = SettingsViewModel()
    @State private var jamendoClientId: String = JamendoCatalogProvider.shared.customClientId ?? ""
    @Environment(\.modelContext) private var modelContext
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Theme.backgroundGradient.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Header Brand Card
                        HStack(spacing: 16) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Theme.purpleGradient)
                                    .frame(width: 56, height: 56)
                                    .purpleGlow(radius: 8, opacity: 0.5)
                                
                                Image(systemName: "headphones")
                                    .font(.system(size: 26, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            
                            VStack(alignment: .leading, spacing: 3) {
                                Text("MelodyBox")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(Theme.textPrimary)
                                Text("Version 1.0.0 (Native SwiftUI & SwiftData)")
                                    .font(.system(size: 12))
                                    .foregroundColor(Theme.textSecondary)
                            }
                            
                            Spacer()
                        }
                        .padding(16)
                        .glassCard(cornerRadius: 16)
                        
                        // Download Preferences
                        VStack(alignment: .leading, spacing: 12) {
                            Text("DOWNLOAD PREFERENCES")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(Theme.textTertiary)
                                .tracking(1)
                                .padding(.leading, 4)
                            
                            Toggle(isOn: $settingsVM.isWifiOnly) {
                                HStack(spacing: 12) {
                                    Image(systemName: "wifi")
                                        .foregroundColor(Theme.purple)
                                        .frame(width: 24)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Download over Wi-Fi Only")
                                            .font(.system(size: 15, weight: .medium))
                                            .foregroundColor(Theme.textPrimary)
                                        Text("Restricts background downloads from using cellular data")
                                            .font(.system(size: 12))
                                            .foregroundColor(Theme.textSecondary)
                                    }
                                }
                            }
                            .tint(Theme.purple)
                            .padding(14)
                            .background(Theme.surfaceElevated.opacity(0.8))
                            .cornerRadius(12)
                        }
                        .glassCard(cornerRadius: 16)
                        
                        // Storage Management
                        VStack(alignment: .leading, spacing: 12) {
                            Text("STORAGE")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(Theme.textTertiary)
                                .tracking(1)
                                .padding(.leading, 4)
                            
                            NavigationLink(destination: StorageCleanupView(settingsVM: settingsVM)) {
                                HStack(spacing: 12) {
                                    Image(systemName: "internaldrive")
                                        .foregroundColor(Theme.purple)
                                        .frame(width: 24)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Storage Usage & Cleanup")
                                            .font(.system(size: 15, weight: .medium))
                                            .foregroundColor(Theme.textPrimary)
                                        Text("\(settingsVM.storageUsedFormatted) used by downloaded tracks")
                                            .font(.system(size: 12))
                                            .foregroundColor(Theme.textSecondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(Theme.textTertiary)
                                }
                                .padding(14)
                                .background(Theme.surfaceElevated.opacity(0.8))
                                .cornerRadius(12)
                            }
                        }
                        .glassCard(cornerRadius: 16)
                        
                        // Licensed API Provider Settings
                        VStack(alignment: .leading, spacing: 12) {
                            Text("MUSIC PROVIDER CONFIGURATION")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(Theme.textTertiary)
                                .tracking(1)
                                .padding(.leading, 4)
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Jamendo Client ID")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(Theme.textSecondary)
                                
                                TextField("Optional client_id (uses curated CC fallback)", text: $jamendoClientId)
                                    .font(.system(size: 14))
                                    .foregroundColor(Theme.textPrimary)
                                    .padding(10)
                                    .background(Theme.surfaceElevated)
                                    .cornerRadius(10)
                                    .onChange(of: jamendoClientId) { _, newValue in
                                        JamendoCatalogProvider.shared.customClientId = newValue.trimmingCharacters(in: .whitespaces)
                                    }
                            }
                            .padding(14)
                            .background(Theme.surfaceElevated.opacity(0.8))
                            .cornerRadius(12)
                        }
                        .glassCard(cornerRadius: 16)
                        
                        // Legal & Licensing
                        VStack(alignment: .leading, spacing: 12) {
                            Text("LEGAL & COMPLIANCE")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(Theme.textTertiary)
                                .tracking(1)
                                .padding(.leading, 4)
                            
                            Button(action: {
                                settingsVM.isLegalSheetPresented = true
                            }) {
                                HStack(spacing: 12) {
                                    Image(systemName: "doc.text.shield.fill")
                                        .foregroundColor(Theme.success)
                                        .frame(width: 24)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Licensing & Attribution Policy")
                                            .font(.system(size: 15, weight: .medium))
                                            .foregroundColor(Theme.textPrimary)
                                        Text("Creative Commons, Public Domain, and DRM compliance")
                                            .font(.system(size: 12))
                                            .foregroundColor(Theme.textSecondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(Theme.textTertiary)
                                }
                                .padding(14)
                                .background(Theme.surfaceElevated.opacity(0.8))
                                .cornerRadius(12)
                            }
                        }
                        .glassCard(cornerRadius: 16)
                        
                        Spacer(minLength: 90) // clearance for mini player
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                settingsVM.refreshStorageInfo()
            }
            .sheet(isPresented: $settingsVM.isLegalSheetPresented) {
                LegalLicensesView()
            }
        }
    }
}
