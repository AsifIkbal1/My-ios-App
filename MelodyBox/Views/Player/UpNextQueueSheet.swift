import SwiftUI

public struct UpNextQueueSheet: View {
    @Bindable var playerVM: PlayerViewModel = .shared
    @Environment(\.dismiss) private var dismiss
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 16) {
                    // Currently Playing Section
                    if let current = playerVM.currentTrack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("NOW PLAYING")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(Theme.purple)
                                .tracking(1)
                                .padding(.horizontal, 20)
                            
                            HStack(spacing: 12) {
                                Image(systemName: "waveform")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(Theme.purple)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(current.title)
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundColor(Theme.textPrimary)
                                        .lineLimit(1)
                                    Text(current.artist)
                                        .font(.system(size: 13, weight: .regular))
                                        .foregroundColor(Theme.textSecondary)
                                        .lineLimit(1)
                                }
                                
                                Spacer()
                                
                                Text(current.formattedDuration)
                                    .font(.system(size: 12, design: .monospaced))
                                    .foregroundColor(Theme.textTertiary)
                            }
                            .padding(14)
                            .glassCard(cornerRadius: 14)
                            .padding(.horizontal, 16)
                        }
                    }
                    
                    // Up Next Section Header
                    HStack {
                        Text("UP NEXT")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(Theme.textSecondary)
                            .tracking(1)
                        
                        Spacer()
                        
                        Text("\(playerVM.audioService.queue.count) tracks")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Theme.textTertiary)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    
                    // Reorderable Queue List
                    if playerVM.audioService.queue.isEmpty {
                        EmptyStateView(
                            icon: "music.note.list",
                            title: "Queue is Empty",
                            message: "Select tracks from your library or search to build your listening queue."
                        )
                    } else {
                        List {
                            ForEach(Array(playerVM.audioService.queue.enumerated()), id: \.element.id) { index, track in
                                HStack(spacing: 12) {
                                    Text("\(index + 1)")
                                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                                        .foregroundColor(index == playerVM.audioService.currentIndex ? Theme.purple : Theme.textTertiary)
                                        .frame(width: 24)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(track.title)
                                            .font(.system(size: 14, weight: index == playerVM.audioService.currentIndex ? .bold : .medium))
                                            .foregroundColor(index == playerVM.audioService.currentIndex ? Theme.purple : Theme.textPrimary)
                                            .lineLimit(1)
                                        Text(track.artist)
                                            .font(.system(size: 12))
                                            .foregroundColor(Theme.textSecondary)
                                            .lineLimit(1)
                                    }
                                    
                                    Spacer()
                                    
                                    Text(track.formattedDuration)
                                        .font(.system(size: 12, design: .monospaced))
                                        .foregroundColor(Theme.textTertiary)
                                }
                                .listRowBackground(Theme.surface.opacity(0.6))
                                .listRowSeparatorTint(Theme.surfaceBorder)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    playerVM.audioService.currentIndex = index
                                    playerVM.play(track: track)
                                }
                            }
                            .onDelete { offsets in
                                playerVM.audioService.removeFromQueue(at: offsets)
                            }
                            .onMove { source, destination in
                                playerVM.audioService.moveQueueItem(from: source, to: destination)
                            }
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                    }
                }
                .padding(.top, 12)
            }
            .navigationTitle("Playback Queue")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    EditButton()
                        .foregroundColor(Theme.purple)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(Theme.purple)
                        .fontWeight(.semibold)
                }
            }
        }
    }
}
