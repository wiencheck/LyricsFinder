//
//  GeniusLyricsFinder.swift
//  LyricsFinder
//
//  Created by Adam Wienconek on 23/10/2024.
//

import Foundation

public class GeniusLyricsFinder: LyricsFinderProtocol {
    
    public var localeIdentifier: String { "en" }
    
    public var domainName: String { "Genius" }
    
    public init() {}
    
    public func makeURL(for song: SongInfo) -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "genius.com"
        
        components.path = "/"
        for component in [song.artist, song.title] {
            components.path += component.replacingOccurrences(of: " ", with: "-")
            components.path += "-"
         //       .normalized
        }
        components.path += "lyrics"
        
        return components.url!
    }
    
    public func extractLyrics(fromHTML html: String) -> String? {
        // The lyrics are generally stored in <div> elements with a class "Lyrics__Container"
        let startMarker = "class=\"Lyrics__Container"
        let endMarker = "</div>"
        
        // Check if the HTML contains the start and end markers
        guard let startRange = html.range(of: startMarker) else {
            return nil // Return nil if the lyrics section is not found
        }
        
        var currentStart = startRange.upperBound
        var lyrics = ""
        
        // Loop through all divs with class "Lyrics__Container"
        while let nextEndRange = html.range(of: endMarker, range: currentStart..<html.endIndex) {
            // Extract the portion of the HTML that contains the lyrics
            let lyricsHTML = html[currentStart..<nextEndRange.lowerBound]
            
            // Remove any HTML tags from the extracted lyrics and append to the final result
            let cleanLyrics = lyricsHTML.replacingOccurrences(of: "<br>", with: "\n")
                .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
                .trimmingCharacters(in: .whitespacesAndNewlines)
            
            lyrics.append(cleanLyrics + "\n")
            
            // Move to the next section if there are multiple containers
            currentStart = nextEndRange.upperBound
            
            // Check if the next Lyrics__Container exists, otherwise break
            guard let _ = html.range(of: startMarker, range: currentStart..<html.endIndex) else {
                break
            }
        }
        
        return lyrics.isEmpty ? nil : lyrics
    }
    
}
