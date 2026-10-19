import XCTest
import SwiftData
@testable import MelodyBox

final class SwiftDataModelTests: XCTestCase {
    var container: ModelContainer!
    var context: ModelContext!
    
    override func setUp() {
        super.setUp()
        do {
            let schema = Schema([
                Track.self,
                Playlist.self,
                DownloadItem.self,
                PlaybackHistoryItem.self
            ])
            let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            container = try ModelContainer(for: schema, configurations: [config])
            context = ModelContext(container)
        } catch {
            XCTFail("Failed to create in-memory ModelContainer: \(error)")
        }
    }
    
    override func tearDown() {
        container = nil
        context = nil
        super.tearDown()
    }
    
    func testTrackCreationAndPersistence() throws {
        let track = Track(
            id: "t_test_01",
            title: "Offline Masterpiece",
            artist: "Sound Architect",
            duration: 215.0,
            licenseType: .creativeCommonsZero,
            isDownloaded: true,
            fileSize: 4_500_000
        )
        
        context.insert(track)
        try context.save()
        
        let descriptor = FetchDescriptor<Track>(predicate: #Predicate { $0.id == "t_test_01" })
        let fetched = try context.fetch(descriptor)
        
        XCTAssertEqual(fetched.count, 1)
        XCTAssertEqual(fetched.first?.title, "Offline Masterpiece")
        XCTAssertEqual(fetched.first?.licenseType, .creativeCommonsZero)
        XCTAssertTrue(fetched.first?.isDownloaded ?? false)
    }
    
    func testPlaylistTrackRelationship() throws {
        let t1 = Track(id: "rel_1", title: "Track A", duration: 100)
        let t2 = Track(id: "rel_2", title: "Track B", duration: 150)
        context.insert(t1)
        context.insert(t2)
        
        let playlist = Playlist(
            title: "Night Drive",
            playlistDescription: "Ambient vibes",
            tracks: [t1, t2]
        )
        context.insert(playlist)
        try context.save()
        
        let descriptor = FetchDescriptor<Playlist>(predicate: #Predicate { $0.title == "Night Drive" })
        let fetched = try context.fetch(descriptor)
        
        XCTAssertEqual(fetched.count, 1)
        XCTAssertEqual(fetched.first?.trackCount, 2)
        XCTAssertEqual(fetched.first?.totalDuration, 250)
    }
}
