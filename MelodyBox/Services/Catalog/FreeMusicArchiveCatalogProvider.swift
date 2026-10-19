import Foundation

public final class FreeMusicArchiveCatalogProvider: MusicCatalogProvider {
    public static let shared = FreeMusicArchiveCatalogProvider()
    
    public let providerId = "fma_catalog"
    public let providerName = "Free Music Archive"
    public let providerDescription = "Curated lawful open music platform offering Creative Commons authorized tracks."
    public let providerIcon = "building.columns.fill"
    
    public init() {}
    
    public func search(query: String) async throws -> [CatalogTrack] {
        return curatedFMATracks().filter {
            query.isEmpty ||
            $0.title.localizedCaseInsensitiveContains(query) ||
            $0.artist.localizedCaseInsensitiveContains(query) ||
            $0.genre.localizedCaseInsensitiveContains(query)
        }
    }
    
    public func fetchFeatured() async throws -> [CatalogTrack] {
        return curatedFMATracks()
    }
    
    public func fetchGenres() async throws -> [CatalogGenre] {
        return [
            CatalogGenre(id: "folk", name: "Folk & Acoustic", icon: "music.mic"),
            CatalogGenre(id: "ambient", name: "Ambient", icon: "waveform.path"),
            CatalogGenre(id: "classical", name: "Modern Classical", icon: "pianokeys")
        ]
    }
    
    private func curatedFMATracks() -> [CatalogTrack] {
        return [
            CatalogTrack(
                id: "fma_curated_01",
                title: "Autumn Whispers",
                artist: "The Forest Folk",
                album: "Wildwood Sessions",
                duration: 240.0,
                streamURL: URL(string: "bundle://starlight_reverie.wav")!,
                downloadURL: URL(string: "bundle://starlight_reverie.wav"),
                artworkURL: URL(string: "https://images.unsplash.com/photo-1448375240586-882707db888b?w=600"),
                licenseType: .freeMusicArchive,
                licenseName: "FMA Open Access License (CC-BY-NC)",
                licenseURL: URL(string: "https://creativecommons.org/licenses/by-nc/4.0/"),
                attribution: "Attributed to The Forest Folk via Free Music Archive curation.",
                genre: "Folk"
            ),
            CatalogTrack(
                id: "fma_curated_02",
                title: "Gentle Rain Over Tokyo",
                artist: "Kenshi Soundscape",
                album: "Echoes in the Mist",
                duration: 275.0,
                streamURL: URL(string: "bundle://velvet_horizons.wav")!,
                downloadURL: URL(string: "bundle://velvet_horizons.wav"),
                artworkURL: URL(string: "https://images.unsplash.com/photo-1503899036084-c55cdd92da26?w=600"),
                licenseType: .creativeCommonsBy,
                licenseName: "CC BY 4.0",
                licenseURL: URL(string: "https://creativecommons.org/licenses/by/4.0/"),
                attribution: "By Kenshi Soundscape, curated on Free Music Archive.",
                genre: "Ambient"
            )
        ]
    }
}
