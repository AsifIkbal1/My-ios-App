import XCTest
@testable import MelodyBox

final class DownloadManagerTests: XCTestCase {
    
    func testDownloadItemProgressCalculations() {
        let item = DownloadItem(
            originalURLString: "https://example.com/song.mp3",
            title: "Test Track",
            progress: 0.55,
            downloadedBytes: 5_500_000,
            totalBytes: 10_000_000
        )
        
        XCTAssertEqual(item.formattedProgress, "55%")
        XCTAssertTrue(item.formattedBytesStatus.contains("/"))
    }
    
    func testDownloadStatusTransitions() {
        let item = DownloadItem(
            originalURLString: "https://example.com/audio.mp3",
            title: "Transition Song",
            status: .pending
        )
        
        XCTAssertEqual(item.status, .pending)
        XCTAssertEqual(item.status.label, "Queued")
        
        item.status = .downloading
        XCTAssertEqual(item.status, .downloading)
        XCTAssertEqual(item.status.label, "Downloading")
        
        item.status = .paused
        XCTAssertEqual(item.status, .paused)
        XCTAssertEqual(item.status.label, "Paused")
        
        item.status = .completed
        XCTAssertEqual(item.status, .completed)
        XCTAssertEqual(item.status.label, "Downloaded")
    }
    
    func testCellularToggle() {
        let manager = BackgroundDownloadManager.shared
        manager.allowsCellularAccess = false
        XCTAssertFalse(manager.allowsCellularAccess)
        
        manager.allowsCellularAccess = true
        XCTAssertTrue(manager.allowsCellularAccess)
    }
}
