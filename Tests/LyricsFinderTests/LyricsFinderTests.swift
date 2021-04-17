import XCTest
@testable import LyricsFinder

final class LyricsFinderTests: XCTestCase {
    let artist = "AC/DC"
    let song = "Back In Black"
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        //XCTAssertEqual(LyricsFinder().text, "Hello, World!")
    }
    
    func testAZLyrics() {
        let finder = AZLyricsFinder()
        
        let url = finder.createUrl(song: song, artist: artist)
        XCTAssertNotNil(url)
        
        LyricsFinder().fetchLyrics(usingProvider: finder) { lyrics in
            //XCTAssertNotNil(lyrics)
        }
    }
}
