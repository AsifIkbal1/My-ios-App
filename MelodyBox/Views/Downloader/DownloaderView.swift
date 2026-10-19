import SwiftUI
import SwiftData

public struct DownloaderView: View {
    @State private var downloaderVM = DownloaderViewModel()
    @Bindable var downloadManager = BackgroundDownloadManager.shared
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \DownloadItem.createdDate, order: .reverse)
    private var allDownloadItems: [DownloadItem]
    
    private var activeItems: [DownloadItem] {
        allDownloadItems.filter { $0.status != .completed }
    }
    
    private var completedItems: [DownloadItem] {
        allDownloadItems.filter { $0.status == .completed }
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Theme.backgroundGradient.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Direct Download Card Button
                        Button(action: {
                            downloaderVM.isDirectURLSheetPresented = true
                        }) {
                            HStack(spacing: 14) {
                                ZStack {
                                    Circle()
                                        .fill(Theme.purpleGradient)
                                        .frame(width: 48, height: 48)
                                    Image(systemName: "link.badge.plus")
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(.white)
                                }
                                .purpleGlow(radius: 8, opacity: 0.4)
                                
                                VStack(alignment: .leading, spacing: 3) {
                                    Text("Download from Direct URL")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(Theme.textPrimary)
                                    
                                    Text("Enter HTTPS link to download authorized audio")
                                        .font(.system(size: 12))
                                        .foregroundColor(Theme.textSecondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(Theme.textTertiary)
                            }
                            .padding(16)
                            .glassCard(cornerRadius: 16)
                        }
                        .buttonStyle(ScaleButtonStyle())
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        
                        // Active Downloads Section
                        if !activeItems.isEmpty {
                            SectionHeader(title: "Active Downloads", count: activeItems.count)
                            
                            LazyVStack(spacing: 10) {
                                ForEach(activeItems) { item in
                                    DownloadRowView(
                                        item: item,
                                        progressState: downloadManager.activeDownloads[item.id],
                                        onPause: {
                                            downloaderVM.pauseDownload(id: item.id)
                                        },
                                        onResume: {
                                            downloaderVM.resumeDownload(item: item)
                                        },
                                        onRetry: {
                                            downloaderVM.retryDownload(item: item)
                                        },
                                        onDelete: {
                                            downloaderVM.cancelAndDelete(item: item, context: modelContext)
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        // Download History / Completed Section
                        if !completedItems.isEmpty {
                            SectionHeader(title: "Download History", count: completedItems.count)
                            
                            LazyVStack(spacing: 10) {
                                ForEach(completedItems) { item in
                                    DownloadRowView(
                                        item: item,
                                        progressState: nil,
                                        onPause: {},
                                        onResume: {},
                                        onRetry: {},
                                        onDelete: {
                                            downloaderVM.cancelAndDelete(item: item, context: modelContext)
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        // Empty State if both are empty
                        if allDownloadItems.isEmpty {
                            EmptyStateView(
                                icon: "arrow.down.circle",
                                title: "No Downloads Yet",
                                message: "Lawfully download Creative Commons tracks from Discover or paste an authorized audio URL.",
                                buttonTitle: "Enter Direct URL",
                                action: { downloaderVM.isDirectURLSheetPresented = true }
                            )
                        }
                        
                        Spacer(minLength: 90) // clearance for mini player
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Downloads")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $downloaderVM.isDirectURLSheetPresented) {
                DirectURLImportSheet()
            }
        }
    }
}
