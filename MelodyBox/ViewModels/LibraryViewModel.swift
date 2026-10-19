import SwiftUI
import SwiftData
import Observation

public enum LibraryFilter: String, CaseIterable {
    case all = "All Songs"
    case downloaded = "Downloaded"
    case favorites = "Favorites"
    case imported = "Imported"
}

public enum LibrarySortOption: String, CaseIterable {
    case recentlyAdded = "Recently Added"
    case titleAZ = "Title (A–Z)"
    case artistAZ = "Artist (A–Z)"
    case duration = "Duration"
}

@Observable
public final class LibraryViewModel {
    public var selectedFilter: LibraryFilter = .all
    public var sortOption: LibrarySortOption = .recentlyAdded
    public var searchQuery: String = ""
    public var isFileImporterPresented: Bool = false
    public var isCreatePlaylistPresented: Bool = false
    public var importStatusMessage: String? = nil
    
    public init() {}
    
    public func filterTracks(_ tracks: [Track]) -> [Track] {
        var filtered = tracks
        
        // Apply category filter
        switch selectedFilter {
        case .all:
            break
        case .downloaded:
            filtered = filtered.filter { $0.isDownloaded }
        case .favorites:
            filtered = filtered.filter { $0.isFavorite }
        case .imported:
            filtered = filtered.filter { $0.source == .fileImport }
        }
        
        // Apply text search
        let query = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !query.isEmpty {
            filtered = filtered.filter {
                $0.title.lowercased().contains(query) ||
                $0.artist.lowercased().contains(query) ||
                $0.album.lowercased().contains(query)
            }
        }
        
        // Apply sorting
        switch sortOption {
        case .recentlyAdded:
            filtered.sort { $0.addedDate > $1.addedDate }
        case .titleAZ:
            filtered.sort { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        case .artistAZ:
            filtered.sort { $0.artist.localizedCaseInsensitiveCompare($1.artist) == .orderedAscending }
        case .duration:
            filtered.sort { $0.duration > $1.duration }
        }
        
        return filtered
    }
    
    public func toggleFavorite(track: Track, context: ModelContext) {
        track.isFavorite.toggle()
        try? context.save()
    }
    
    public func deleteTrack(track: Track, context: ModelContext) {
        // If playing this track, stop or skip
        if AudioPlayerService.shared.currentTrack?.id == track.id {
            AudioPlayerService.shared.nextTrack()
        }
        
        // Delete audio file from disk
        StorageManager.shared.deleteTrackFile(relativeFilePath: track.relativeFilePath)
        
        // Delete from SwiftData
        context.delete(track)
        try? context.save()
    }
    
    public func handleFileImport(result: Result<[URL], Error>, context: ModelContext) {
        switch result {
        case .success(let urls):
            Task {
                do {
                    let imported = try await FileImportService.shared.importAudioFiles(from: urls, into: context)
                    await MainActor.run {
                        self.importStatusMessage = "Successfully imported \(imported.count) audio file(s)."
                    }
                } catch {
                    await MainActor.run {
                        self.importStatusMessage = "Import failed: \(error.localizedDescription)"
                    }
                }
            }
        case .failure(let error):
            self.importStatusMessage = "File selection error: \(error.localizedDescription)"
        }
    }
    
    public func createPlaylist(title: String, description: String, context: ModelContext) {
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let playlist = Playlist(
            title: title.trimmingCharacters(in: .whitespaces),
            playlistDescription: description.trimmingCharacters(in: .whitespaces)
        )
        context.insert(playlist)
        try? context.save()
    }
}
