import SwiftUI
import SwiftData

public struct DirectURLImportSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var downloaderVM = DownloaderViewModel()
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Header
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(Theme.purple.opacity(0.15))
                                    .frame(width: 56, height: 56)
                                Image(systemName: "link.badge.plus")
                                    .font(.system(size: 26))
                                    .foregroundColor(Theme.purple)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Direct Audio Download")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(Theme.textPrimary)
                                Text("Lawful direct MP3/M4A/WAV download")
                                    .font(.system(size: 13))
                                    .foregroundColor(Theme.textSecondary)
                            }
                        }
                        .padding(.top, 12)
                        
                        // Input URL
                        VStack(alignment: .leading, spacing: 8) {
                            Text("AUDIO URL (HTTPS)")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(Theme.textTertiary)
                                .tracking(1)
                            
                            TextField("https://example.com/audio.mp3", text: $downloaderVM.inputURLString)
                                .keyboardType(.URL)
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.never)
                                .font(.system(size: 14))
                                .foregroundColor(Theme.textPrimary)
                                .padding(12)
                                .background(Theme.surfaceElevated)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .strokeBorder(Theme.surfaceBorder, lineWidth: 1)
                                )
                        }
                        
                        // Title & Artist Fields
                        VStack(alignment: .leading, spacing: 14) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("TITLE (OPTIONAL)")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(Theme.textTertiary)
                                    .tracking(1)
                                
                                TextField("Auto-extracted from audio tags if empty", text: $downloaderVM.inputTitle)
                                    .font(.system(size: 14))
                                    .foregroundColor(Theme.textPrimary)
                                    .padding(12)
                                    .background(Theme.surfaceElevated)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .strokeBorder(Theme.surfaceBorder, lineWidth: 1)
                                    )
                            }
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text("ARTIST (OPTIONAL)")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(Theme.textTertiary)
                                    .tracking(1)
                                
                                TextField("Artist or creator name", text: $downloaderVM.inputArtist)
                                    .font(.system(size: 14))
                                    .foregroundColor(Theme.textPrimary)
                                    .padding(12)
                                    .background(Theme.surfaceElevated)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .strokeBorder(Theme.surfaceBorder, lineWidth: 1)
                                    )
                            }
                        }
                        
                        // License Designation
                        VStack(alignment: .leading, spacing: 8) {
                            Text("LICENSE & PERMISSION STATUS")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(Theme.textTertiary)
                                .tracking(1)
                            
                            Picker("License", selection: $downloaderVM.selectedLicense) {
                                Text("Direct Authorized Audio").tag(LicenseType.directAuthorized)
                                Text("CC0 / Public Domain").tag(LicenseType.publicDomain)
                                Text("CC BY (Attribution)").tag(LicenseType.creativeCommonsBy)
                                Text("CC BY-SA (ShareAlike)").tag(LicenseType.creativeCommonsBySa)
                            }
                            .pickerStyle(.menu)
                            .padding(10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Theme.surfaceElevated)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(Theme.surfaceBorder, lineWidth: 1)
                            )
                        }
                        
                        // Legal Compliance Warning
                        VStack(alignment: .leading, spacing: 6) {
                            HStack(spacing: 6) {
                                Image(systemName: "checkmark.shield.fill")
                                    .foregroundColor(Theme.success)
                                Text("Lawful Content Guarantee")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(Theme.textPrimary)
                            }
                            
                            Text("You confirm that you possess explicit authorization, rights, or a Creative Commons/Public Domain license to download and play this audio offline for personal use.")
                                .font(.system(size: 12))
                                .foregroundColor(Theme.textSecondary)
                                .lineSpacing(3)
                        }
                        .padding(14)
                        .glassCard(cornerRadius: 12)
                        
                        // Error message
                        if let error = downloaderVM.validationErrorMessage {
                            Text(error)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(Theme.error)
                        }
                        
                        // Submit Button
                        GradientButton(
                            title: downloaderVM.isValidatingURL ? "Validating URL..." : "Start Background Download",
                            icon: "arrow.down"
                        ) {
                            downloaderVM.validateAndStartDirectDownload(context: modelContext)
                            dismiss()
                        }
                        .disabled(downloaderVM.isValidatingURL || downloaderVM.inputURLString.trimmingCharacters(in: .whitespaces).isEmpty)
                        .opacity(downloaderVM.inputURLString.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1.0)
                        
                        Spacer(minLength: 40)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Direct Audio URL")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(Theme.textSecondary)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}
