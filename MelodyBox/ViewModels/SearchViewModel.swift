import SwiftUI
import SwiftData
import Observation

@Observable
public final class SearchViewModel {
    public var query: String = ""
    public var searchResults: [CatalogTrack] = []
    public var genres: [CatalogGenre] = []
    public var selectedGenre: CatalogGenre? = nil
    public var isSearching: Bool = false
    public var errorMessage: String? = nil
    
    // Providers
    public let providers: [MusicCatalogProvider] = [
        DemoCatalogProvider.shared,
        JamendoCatalogProvider.shared,
        FreeMusicArchiveCatalogProvider.shared
    ]
    public var selectedProviderIndex: Int = 0 {
        didSet {
            Task { await performSearch() }
        }
    }
    
    public var currentProvider: MusicCatalogProvider {
        providers[selectedProviderIndex]
    }
    
    private var searchTask: Task<Void, Never>?
    
    public init() {
        Task {
            await loadGenres()
            await performSearch()
        }
    }
    
    public func loadGenres() async {
        do {
            genres = try await currentProvider.fetchGenres()
            if selectedGenre == nil {
                selectedGenre = genres.first
            }
        } catch {
            print("Failed to load genres: \(error)")
        }
    }
    
    public func onQueryChanged() {
        searchTask?.cancel()
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000) // 300ms debounce
            guard !Task.isCancelled else { return }
            await performSearch()
        }
    }
    
    public func selectGenre(_ genre: CatalogGenre) {
        selectedGenre = genre
        Task { await performSearch() }
    }
    
    public func performSearch() async {
        isSearching = true
        errorMessage = nil
        do {
            var results = try await currentProvider.search(query: query)
            if let genre = selectedGenre, genre.id != "all" {
                results = results.filter { $0.genre.localizedCaseInsensitiveContains(genre.name) }
            }
            searchResults = results
        } catch {
            errorMessage = "Unable to fetch tracks from \(currentProvider.providerName)."
        }
        isSearching = false
    }
    
    /// Previews or plays track immediately
    public func previewTrack(_ catalogTrack: CatalogTrack) {
        let track = catalogTrack.toTrackEntity()
        AudioPlayerService.shared.play(track: track)
    }
    
    /// Queues a lawful download task for authorized tracks
    public func queueDownload(for catalogTrack: CatalogTrack, context: ModelContext) {
        guard catalogTrack.isDownloadAllowed, let downloadURL = catalogTrack.downloadURL else { return }
        
        let downloadItem = DownloadItem(
            id: UUID().uuidString,
            originalURLString: downloadURL.absoluteString,
            title: catalogTrack.title,
            artist: catalogTrack.artist,
            album: catalogTrack.album,
            artworkURLString: catalogTrack.artworkURL?.absoluteString,
            licenseType: catalogTrack.licenseType,
            licenseName: catalogTrack.licenseName
        )
        
        context.insert(downloadItem)
        try? context.save()
        
        BackgroundDownloadManager.shared.startDownload(item: downloadItem)
    }
}
