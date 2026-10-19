import Foundation
import SwiftData

public final class DemoCatalogProvider: MusicCatalogProvider {
    public static let shared = DemoCatalogProvider()
    
    public let providerId = "demo_catalog"
    public let providerName = "Lawful Open Catalog"
    public let providerDescription = "Curated public domain and Creative Commons authorized tracks for lawful offline listening."
    public let providerIcon = "sparkles"
    
    private var allTracks: [CatalogTrack] = []
    
    public init() {
        buildCatalog()
    }
    
    private func buildCatalog() {
        // Lawful Public Domain & Creative Commons Showcase
        allTracks = [
            CatalogTrack(
                id: "mb_demo_01",
                title: "Midnight Neon",
                artist: "MelodyBox Studio",
                album: "Cyber Horizon",
                duration: 12.0,
                streamURL: URL(string: "bundle://midnight_neon.wav")!,
                downloadURL: URL(string: "bundle://midnight_neon.wav"),
                artworkURL: URL(string: "https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=600"),
                licenseType: .creativeCommonsZero,
                licenseName: "CC0 1.0 Public Domain",
                licenseURL: URL(string: "https://creativecommons.org/publicdomain/zero/1.0/"),
                attribution: "Provided royalty-free with MelodyBox app bundle under CC0.",
                genre: "Synthwave"
            ),
            CatalogTrack(
                id: "mb_demo_02",
                title: "Velvet Horizons",
                artist: "Luna Sol",
                album: "Lofi Dreamscapes",
                duration: 10.0,
                streamURL: URL(string: "bundle://velvet_horizons.wav")!,
                downloadURL: URL(string: "bundle://velvet_horizons.wav"),
                artworkURL: URL(string: "https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=600"),
                licenseType: .creativeCommonsBy,
                licenseName: "CC BY 4.0 (Attribution)",
                licenseURL: URL(string: "https://creativecommons.org/licenses/by/4.0/"),
                attribution: "Music by Luna Sol under CC-BY 4.0 license.",
                genre: "Lo-Fi"
            ),
            CatalogTrack(
                id: "mb_demo_03",
                title: "Starlight Reverie",
                artist: "Aria Vance",
                album: "Acoustic Nocturnes",
                duration: 14.0,
                streamURL: URL(string: "bundle://starlight_reverie.wav")!,
                downloadURL: URL(string: "bundle://starlight_reverie.wav"),
                artworkURL: URL(string: "https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=600"),
                licenseType: .creativeCommonsBySa,
                licenseName: "CC BY-SA 4.0",
                licenseURL: URL(string: "https://creativecommons.org/licenses/by-sa/4.0/"),
                attribution: "Music by Aria Vance under CC-BY-SA 4.0 terms.",
                genre: "Acoustic"
            ),
            CatalogTrack(
                id: "mb_demo_04",
                title: "Moonlight Sonata (Adagio)",
                artist: "Ludwig van Beethoven",
                album: "Classical Heritage Masterpieces",
                duration: 315.0,
                streamURL: URL(string: "https://upload.wikimedia.org/wikipedia/commons/e/eb/Beethoven_Moonlight_1st_movement.ogg")!,
                downloadURL: URL(string: "https://upload.wikimedia.org/wikipedia/commons/e/eb/Beethoven_Moonlight_1st_movement.ogg"),
                artworkURL: URL(string: "https://images.unsplash.com/photo-1520523839898-507121633633?w=600"),
                licenseType: .publicDomain,
                licenseName: "Public Domain (Musopen / Wikimedia Commons)",
                licenseURL: URL(string: "https://musopen.org/music/performer/musopen-symphony/"),
                attribution: "Performed by Paul Pitman, released into the public domain via Musopen.",
                genre: "Classical"
            ),
            CatalogTrack(
                id: "mb_demo_05",
                title: "Clair de Lune",
                artist: "Claude Debussy",
                album: "Suite Bergamasque",
                duration: 304.0,
                streamURL: URL(string: "https://upload.wikimedia.org/wikipedia/commons/2/21/Claude_Debussy_-_Clair_de_lune.ogg")!,
                downloadURL: URL(string: "https://upload.wikimedia.org/wikipedia/commons/2/21/Claude_Debussy_-_Clair_de_lune.ogg"),
                artworkURL: URL(string: "https://images.unsplash.com/photo-1507838153414-b4b713384a76?w=600"),
                licenseType: .publicDomain,
                licenseName: "Public Domain (Musopen)",
                licenseURL: URL(string: "https://musopen.org/"),
                attribution: "Public Domain audio performance via Musopen open access library.",
                genre: "Classical"
            ),
            CatalogTrack(
                id: "mb_demo_06",
                title: "Spring - The Four Seasons",
                artist: "Antonio Vivaldi",
                album: "Baroque Concertos",
                duration: 216.0,
                streamURL: URL(string: "https://upload.wikimedia.org/wikipedia/commons/3/3c/Vivaldi_Spring_mvt_1_Allegro.ogg")!,
                downloadURL: URL(string: "https://upload.wikimedia.org/wikipedia/commons/3/3c/Vivaldi_Spring_mvt_1_Allegro.ogg"),
                artworkURL: URL(string: "https://images.unsplash.com/photo-1465847899084-d164df4dedc6?w=600"),
                licenseType: .creativeCommonsBy,
                licenseName: "CC BY 3.0 US",
                licenseURL: URL(string: "https://creativecommons.org/licenses/by/3.0/us/"),
                attribution: "Performed by John Harrison with the Wichita State University Chamber Players.",
                genre: "Classical"
            ),
            CatalogTrack(
                id: "mb_demo_07",
                title: "Gymnopédie No. 1",
                artist: "Erik Satie",
                album: "Impressionist Solos",
                duration: 202.0,
                streamURL: URL(string: "https://upload.wikimedia.org/wikipedia/commons/b/b2/Erik_Satie_-_Gymnopedie_No._1.ogg")!,
                downloadURL: URL(string: "https://upload.wikimedia.org/wikipedia/commons/b/b2/Erik_Satie_-_Gymnopedie_No._1.ogg"),
                artworkURL: URL(string: "https://images.unsplash.com/photo-1497911270199-1c552ee64aa4?w=600"),
                licenseType: .publicDomain,
                licenseName: "Public Domain Worldwide",
                licenseURL: URL(string: "https://musopen.org/"),
                attribution: "Public Domain performance by Robin Alciatore via Musopen.",
                genre: "Ambient"
            ),
            CatalogTrack(
                id: "mb_demo_08",
                title: "Nocturne in E-flat Major, Op. 9 No. 2",
                artist: "Frédéric Chopin",
                album: "Romantic Nocturnes",
                duration: 268.0,
                streamURL: URL(string: "https://upload.wikimedia.org/wikipedia/commons/b/b0/Chopin_Nocturne_Op._9_No._2.ogg")!,
                downloadURL: URL(string: "https://upload.wikimedia.org/wikipedia/commons/b/b0/Chopin_Nocturne_Op._9_No._2.ogg"),
                artworkURL: URL(string: "https://images.unsplash.com/photo-1487180144351-b8472da7d491?w=600"),
                licenseType: .publicDomain,
                licenseName: "Public Domain (Musopen)",
                licenseURL: URL(string: "https://musopen.org/"),
                attribution: "Performed by Luke Faulkner, licensed for public open access.",
                genre: "Classical"
            ),
            CatalogTrack(
                id: "mb_demo_09",
                title: "Live Festival Preview (Stream Only)",
                artist: "Echoes of Aurora",
                album: "Live from London",
                duration: 180.0,
                streamURL: URL(string: "bundle://velvet_horizons.wav")!,
                downloadURL: nil, // Download explicitly restricted
                artworkURL: URL(string: "https://images.unsplash.com/photo-1429962714451-bb934ecdc4ec?w=600"),
                licenseType: .streamOnly,
                licenseName: "Stream Only — Preview License",
                licenseURL: nil,
                attribution: "Authorized for streaming preview only. Download prohibited by rights-holder.",
                genre: "Electronic"
            )
        ]
    }
    
    public func search(query: String) async throws -> [CatalogTrack] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if trimmed.isEmpty {
            return allTracks
        }
        return allTracks.filter { track in
            track.title.lowercased().contains(trimmed) ||
            track.artist.lowercased().contains(trimmed) ||
            track.genre.lowercased().contains(trimmed) ||
            track.licenseName.lowercased().contains(trimmed)
        }
    }
    
    public func fetchFeatured() async throws -> [CatalogTrack] {
        return allTracks
    }
    
    public func fetchGenres() async throws -> [CatalogGenre] {
        return [
            CatalogGenre(id: "all", name: "All Genres", icon: "music.note.list"),
            CatalogGenre(id: "classical", name: "Classical", icon: "pianokeys"),
            CatalogGenre(id: "lofi", name: "Lo-Fi", icon: "headphones"),
            CatalogGenre(id: "synthwave", name: "Synthwave", icon: "waveform"),
            CatalogGenre(id: "acoustic", name: "Acoustic", icon: "guitars"),
            CatalogGenre(id: "ambient", name: "Ambient", icon: "wind")
        ]
    }
    
    /// Seeds the default bundled offline tracks into SwiftData on first run
    public func seedInitialTracksIfNeeded(context: ModelContext) {
        let descriptor = FetchDescriptor<Track>()
        let existingCount = (try? context.fetch(descriptor).count) ?? 0
        guard existingCount == 0 else { return }
        
        let initialTracks: [Track] = [
            Track(
                id: "bundled_01",
                title: "Midnight Neon",
                artist: "MelodyBox Studio",
                album: "Cyber Horizon",
                duration: 12.0,
                relativeFilePath: "bundle://midnight_neon.wav",
                source: .demoCatalog,
                licenseType: .creativeCommonsZero,
                licenseName: "CC0 1.0 Public Domain",
                attributionText: "Bundled royalty-free starter track.",
                isFavorite: true,
                isDownloaded: true,
                fileSize: 2116844
            ),
            Track(
                id: "bundled_02",
                title: "Velvet Horizons",
                artist: "Luna Sol",
                album: "Lofi Dreamscapes",
                duration: 10.0,
                relativeFilePath: "bundle://velvet_horizons.wav",
                source: .demoCatalog,
                licenseType: .creativeCommonsBy,
                licenseName: "CC BY 4.0",
                attributionText: "Music by Luna Sol under CC-BY 4.0.",
                isFavorite: true,
                isDownloaded: true,
                fileSize: 1764044
            ),
            Track(
                id: "bundled_03",
                title: "Starlight Reverie",
                artist: "Aria Vance",
                album: "Acoustic Nocturnes",
                duration: 14.0,
                relativeFilePath: "bundle://starlight_reverie.wav",
                source: .demoCatalog,
                licenseType: .creativeCommonsBySa,
                licenseName: "CC BY-SA 4.0",
                attributionText: "Music by Aria Vance under CC-BY-SA 4.0.",
                isFavorite: false,
                isDownloaded: true,
                fileSize: 2469644
            )
        ]
        
        for track in initialTracks {
            context.insert(track)
        }
        
        // Create a default playlist "Favorites & Chill"
        let defaultPlaylist = Playlist(
            title: "Midnight Vibez",
            playlistDescription: "Curated lawful offline starter tracks.",
            tracks: initialTracks
        )
        context.insert(defaultPlaylist)
        
        try? context.save()
    }
}
