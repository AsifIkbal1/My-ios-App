import SwiftUI
import SwiftData
import Observation

@Observable
public final class HomeViewModel {
    public var featuredTracks: [CatalogTrack] = []
    public var isLoading: Bool = false
    public var errorMessage: String? = nil
    
    public init() {}
    
    public func loadFeatured() async {
        isLoading = true
        errorMessage = nil
        do {
            featuredTracks = try await DemoCatalogProvider.shared.fetchFeatured()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
