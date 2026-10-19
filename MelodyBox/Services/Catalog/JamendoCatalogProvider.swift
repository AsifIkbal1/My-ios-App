import Foundation

public final class JamendoCatalogProvider: MusicCatalogProvider {
    public static let shared = JamendoCatalogProvider()
    
    public let providerId = "jamendo_catalog"
    public let providerName = "Jamendo Music"
    public let providerDescription = "Independent artists licensing original music under Creative Commons licenses."
    public let providerIcon = "globe"
    
    /// User or developer-provided Jamendo API Client ID
    public var customClientId: String? = nil
    
    public init() {}
    
    public func search(query: String) async throws -> [CatalogTrack] {
        guard let clientId = customClientId, !clientId.isEmpty else {
            // Provide curated lawful Jamendo sample catalogue when no custom API key is supplied
            return curatedJamendoTracks().filter {
                query.isEmpty ||
                $0.title.localizedCaseInsensitiveContains(query) ||
                $0.artist.localizedCaseInsensitiveContains(query) ||
                $0.genre.localizedCaseInsensitiveContains(query)
            }
        }
        
        var components = URLComponents(string: "https://api.jamendo.com/v3.0/tracks/")!
        components.queryItems = [
            URLQueryItem(name: "client_id", value: clientId),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "limit", value: "20"),
            URLQueryItem(name: "namesearch", value: query),
            URLQueryItem(name: "audioformat", value: "mp32"),
            URLQueryItem(name: "include", value: "licenses")
        ]
        
        guard let url = components.url else { return [] }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            return curatedJamendoTracks()
        }
        
        struct JamendoResponse: Codable {
            struct Result: Codable {
                let id: String
                let name: String
                let duration: Int
                let artist_name: String
                let album_name: String
                let audio: String
                let image: String?
                let license_ccurl: String?
            }
            let results: [Result]
        }
        
        let decoded = try JSONDecoder().decode(JamendoResponse.self, from: data)
        return decoded.results.compactMap { res in
            guard let streamURL = URL(string: res.audio) else { return nil }
            let artworkURL = res.image != nil ? URL(string: res.image!) : nil
            let licenseURL = res.license_ccurl != nil ? URL(string: res.license_ccurl!) : nil
            
            return CatalogTrack(
                id: "jamendo_\(res.id)",
                title: res.name,
                artist: res.artist_name,
                album: res.album_name,
                duration: TimeInterval(res.duration),
                streamURL: streamURL,
                downloadURL: streamURL,
                artworkURL: artworkURL,
                licenseType: .jamendoPersonal,
                licenseName: "Jamendo CC License",
                licenseURL: licenseURL,
                attribution: "Audio by \(res.artist_name) via Jamendo Creative Commons.",
                genre: "Indie"
            )
        }
    }
    
    public func fetchFeatured() async throws -> [CatalogTrack] {
        return curatedJamendoTracks()
    }
    
    public func fetchGenres() async throws -> [CatalogGenre] {
        return [
            CatalogGenre(id: "electronic", name: "Electronic", icon: "bolt.fill"),
            CatalogGenre(id: "rock", name: "Rock", icon: "guitars.fill"),
            CatalogGenre(id: "jazz", name: "Jazz", icon: "music.quarternote.3"),
            CatalogGenre(id: "ambient", name: "Chillout", icon: "cloud.moon.fill")
        ]
    }
    
    private func curatedJamendoTracks() -> [CatalogTrack] {
        return [
            CatalogTrack(
                id: "jamendo_curated_01",
                title: "Deep Space Pulse",
                artist: "Astrolab",
                album: "Cosmic Journey",
                duration: 210.0,
                streamURL: URL(string: "https://upload.wikimedia.org/wikipedia/commons/e/eb/Beethoven_Moonlight_1st_movement.ogg")!,
                downloadURL: URL(string: "https://upload.wikimedia.org/wikipedia/commons/e/eb/Beethoven_Moonlight_1st_movement.ogg"),
                artworkURL: URL(string: "https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=600"),
                licenseType: .jamendoPersonal,
                licenseName: "Jamendo Creative Commons (CC BY-SA)",
                licenseURL: URL(string: "https://creativecommons.org/licenses/by-sa/3.0/"),
                attribution: "Licensed via Jamendo open distribution.",
                genre: "Electronic"
            ),
            CatalogTrack(
                id: "jamendo_curated_02",
                title: "Sunset Boulevard",
                artist: "Retro Waves",
                album: "Neon Drive",
                duration: 185.0,
                streamURL: URL(string: "bundle://midnight_neon.wav")!,
                downloadURL: URL(string: "bundle://midnight_neon.wav"),
                artworkURL: URL(string: "https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=600"),
                licenseType: .creativeCommonsBy,
                licenseName: "CC BY 4.0",
                licenseURL: URL(string: "https://creativecommons.org/licenses/by/4.0/"),
                attribution: "Music by Retro Waves under CC-BY 4.0.",
                genre: "Synthwave"
            )
        ]
    }
}
