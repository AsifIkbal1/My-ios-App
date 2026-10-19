import SwiftUI
import SwiftData

public struct StorageCleanupView: View {
    @Bindable var settingsVM: SettingsViewModel
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    public var body: some View {
        ZStack {
            Theme.backgroundGradient.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 20) {
                // Storage Metric Card
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Audio Storage Used")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(Theme.textTertiary)
                            Text(settingsVM.storageUsedFormatted)
                                .font(.system(size: 32, weight: .black))
                                .foregroundColor(Theme.purple)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "internaldrive.fill")
                            .font(.system(size: 36))
                            .foregroundColor(Theme.purple.opacity(0.8))
                    }
                    
                    Divider().background(Theme.surfaceBorder)
                    
                    HStack {
                        Text("Available Device Space:")
                            .font(.system(size: 13))
                            .foregroundColor(Theme.textSecondary)
                        Spacer()
                        Text(settingsVM.storageAvailableFormatted)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(Theme.textPrimary)
                    }
                }
                .padding(20)
                .glassCard(cornerRadius: 16)
                
                // Storage Cleanup Action
                VStack(alignment: .leading, spacing: 10) {
                    Text("Cleanup Actions")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(Theme.textPrimary)
                    
                    Text("Clearing downloaded files will permanently delete local audio files from your device. Tracks can be downloaded again anytime.")
                        .font(.system(size: 13))
                        .foregroundColor(Theme.textSecondary)
                        .lineSpacing(3)
                    
                    Button(action: {
                        settingsVM.isClearStorageAlertPresented = true
                    }) {
                        HStack {
                            Image(systemName: "trash.fill")
                            Text("Delete All Downloaded Tracks")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(Theme.error)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Theme.error.opacity(0.12))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(Theme.error.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .padding(.top, 8)
                }
                .padding(20)
                .glassCard(cornerRadius: 16)
                
                Spacer()
            }
            .padding(20)
        }
        .navigationTitle("Storage Management")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Clear All Downloaded Audio?", isPresented: $settingsVM.isClearStorageAlertPresented) {
            Button("Cancel", role: .cancel) {}
            Button("Clear All", role: .destructive) {
                settingsVM.clearAllDownloads(context: modelContext)
            }
        } message: {
            Text("This will remove all downloaded offline files from device storage.")
        }
    }
}
