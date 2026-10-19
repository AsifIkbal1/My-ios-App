import XCTest
@testable import MelodyBox

final class AudioPlayerServiceTests: XCTestCase {
    var playerService: AudioPlayerService!
    
    override func setUp() {
        super.setUp()
        playerService = AudioPlayerService()
    }
    
    override func tearDown() {
        playerService = nil
        super.tearDown()
    }
    
    func testQueueOperations() {
        let t1 = Track(id: "1", title: "Track 1")
        let t2 = Track(id: "2", title: "Track 2")
        let t3 = Track(id: "3", title: "Track 3")
        
        playerService.play(track: t1, from: [t1, t2])
        XCTAssertEqual(playerService.queue.count, 2)
        XCTAssertEqual(playerService.currentIndex, 0)
        XCTAssertEqual(playerService.currentTrack?.id, "1")
        
        // Add to queue
        playerService.addToQueue(t3)
        XCTAssertEqual(playerService.queue.count, 3)
        XCTAssertEqual(playerService.queue.last?.id, "3")
        
        // Play next
        let t4 = Track(id: "4", title: "Track 4")
        playerService.playNext(t4)
        XCTAssertEqual(playerService.queue[1].id, "4")
    }
    
    func testShufflePreservesTracks() {
        let tracks = (1...5).map { Track(id: "\($0)", title: "Song \($0)") }
        playerService.play(track: tracks[0], from: tracks)
        
        XCTAssertFalse(playerService.isShuffled)
        playerService.toggleShuffle()
        XCTAssertTrue(playerService.isShuffled)
        XCTAssertEqual(playerService.queue.count, 5)
        XCTAssertEqual(playerService.queue[0].id, "1") // Current track remains at start
        
        // Toggle off restores original queue order
        playerService.toggleShuffle()
        XCTAssertFalse(playerService.isShuffled)
        XCTAssertEqual(playerService.queue.map { $0.id }, ["1", "2", "3", "4", "5"])
    }
    
    func testRepeatModeCycle() {
        XCTAssertEqual(playerService.repeatMode, .off)
        playerService.cycleRepeatMode()
        XCTAssertEqual(playerService.repeatMode, .all)
        playerService.cycleRepeatMode()
        XCTAssertEqual(playerService.repeatMode, .one)
        playerService.cycleRepeatMode()
        XCTAssertEqual(playerService.repeatMode, .off)
    }
    
    func testDurationFormatting() {
        XCTAssertEqual(TimeInterval(0).formattedDuration, "0:00")
        XCTAssertEqual(TimeInterval(45).formattedDuration, "0:45")
        XCTAssertEqual(TimeInterval(125).formattedDuration, "2:05")
        XCTAssertEqual(TimeInterval(3665).formattedDuration, "1:01:05")
    }
}
