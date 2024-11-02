//
//  File.swift
//  
//
//  Created by Adam Wienconek on 02/03/2021.
//

import Foundation
import SwiftSoup

public struct MetroLyricsFinder: LyricsFinderProtocol {    
    public var localeIdentifier: String {
        return "en"
    }
    
    public var domainName: String {
        return "MetroLyrics"
    }
    
    private func fixParameter(_ parameter: String) -> String {
        return parameter
            .folding(options: .diacriticInsensitive, locale: .current)
            .replaceCharactersFromSet(characterSet: .whitespaces, replacementString: "-")
            .lowercased()
    }
    
    public func makeURL(for song: SongInfo) -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "metrolyrics.com"
        components.path = "/\(fixParameter(song.title))-lyrics-\(fixParameter(song.artist))"
        
        return components.url!
    }
        
    public func extractLyrics(fromHTML html: String) -> String? {
        do {
            // Replacing <br> tag manually because Soup would just remove them and all text would be missing spaces.
            let newline = "__newline"
            let doc = try SwiftSoup.parse(html)//.replacingOccurrences(of: "<br>", with: newline))
            guard let element = try doc.getAllElements()
                    .filter ({ $0.tagName() == "div" })
                    .first(where: { element in
                try element.className() == "js-lyric-text" && element.id() == "lyrics-body-text"
            }) else { return nil }
            
            let text = try element.text()
                //.replacingOccurrences(of: newline, with: "\n")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            
            if text.isEmpty {
                return nil
            }
            return text
        } catch {
            print("*** Metrolyrics parsing error: \(error)")
        }
        return nil
    }
}

extension String {
    func replaceCharactersFromSet(characterSet: CharacterSet, replacementString: String = "") -> String {
        return components(separatedBy: characterSet).joined(separator: replacementString)
    }
}
