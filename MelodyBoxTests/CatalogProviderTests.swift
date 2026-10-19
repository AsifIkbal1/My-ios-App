import XCTest
@testable import MelodyBox

final class CatalogProviderTests: XCTestCase {
    
    func testLicensePermissions() {
        XCTAssertTrue(LicenseType.publicDomain.isDownloadAllowed)
        XCTAssertTrue(LicenseType.creativeCommonsZero.isDownloadAllowed)
        XCTAssertTrue(LicenseType.creativeCommonsBy.isDownloadAllowed)
        XCTAssertTrue(LicenseType.jamendoPersonal.isDownloadAllowed)
        XCTAssertFalse(LicenseType.streamOnly.isDownloadAllowed)
    }
    
    func testDemoCatalogSearch() async throws {
        let provider = DemoCatalogProvider.shared
        
        let allResults = try await provider.search(query: "")
        XCTAssertFalse(allResults.isEmpty)
        
        let beethoven = try await provider.search(query: "Beethoven")
        XCTAssertFalse(beethoven.isEmpty)
        XCTAssertTrue(beethoven.first?.title.contains("Moonlight") ?? false)
        
        let synth = try await provider.search(query: "Synthwave")
        XCTAssertFalse(synth.isEmpty)
    }
    
    func testCatalogTrackToTrackEntityConversion() {
        let catalogTrack = CatalogTrack(
            id: "cat_01",
            title: "Test Lawful Track",
            artist: "Open Artist",
            album: "Open Horizons",
            duration: 180.0,
            streamURL: URL(string: "https://example.com/test.mp3")!,
            licenseType: .creativeCommonsBy
        )
        
        let entity = catalogTrack.toTrackEntity()
        XCTAssertEqual(entity.id, "cat_01")
        XCTAssertEqual(entity.title, "Test Lawful Track")
        XCTAssertEqual(entity.licenseType, .creativeCommonsBy)
        XCTAssertFalse(entity.isDownloaded)
    }
}
