import SwiftUI
import SwiftData

public struct CreatePlaylistSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var playlistTitle: String = ""
    @State private var playlistDescription: String = ""
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Header Icon
                    ZStack {
                        Circle()
                            .fill(Theme.purple.opacity(0.15))
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: "music.note.list")
                            .font(.system(size: 36))
                            .foregroundColor(Theme.purple)
                    }
                    .padding(.top, 16)
                    
                    // Input Fields
                    VStack(spacing: 14) {
                        TextField("Playlist Name", text: $playlistTitle)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Theme.textPrimary)
                            .padding(14)
                            .background(Theme.surfaceElevated)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(Theme.surfaceBorder, lineWidth: 1)
                            )
                        
                        TextField("Description (optional)", text: $playlistDescription)
                            .font(.system(size: 14))
                            .foregroundColor(Theme.textPrimary)
                            .padding(14)
                            .background(Theme.surfaceElevated)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(Theme.surfaceBorder, lineWidth: 1)
                            )
                    }
                    .padding(.horizontal, 20)
                    
                    GradientButton(title: "Create Playlist", icon: "plus") {
                        let trimmed = playlistTitle.trimmingCharacters(in: .whitespaces)
                        guard !trimmed.isEmpty else { return }
                        let playlist = Playlist(
                            title: trimmed,
                            playlistDescription: playlistDescription.trimmingCharacters(in: .whitespaces)
                        )
                        modelContext.insert(playlist)
                        try? modelContext.save()
                        dismiss()
                    }
                    .disabled(playlistTitle.trimmingCharacters(in: .whitespaces).isEmpty)
                    .opacity(playlistTitle.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1.0)
                    .padding(.top, 12)
                    
                    Spacer()
                }
            }
            .navigationTitle("New Playlist")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(Theme.textSecondary)
                }
            }
        }
        .presentationDetents([.medium])
    }
}
