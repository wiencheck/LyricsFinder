//
//  AZLyricsFinder.swift
//  LyricsGrabber
//
//  Created by Adam Wienconek on 02/03/2021.
//

import Foundation
import SwiftSoup

public struct AZLyricsFinder: LyricsFinderProtocol {    
    public var localeIdentifier: String {
        return "en"
    }
    
    var domainName: String {
        return "AZLyrics"
    }
    
    private func fixParameter(_ parameter: String) -> String {
        return parameter
            .folding(options: .diacriticInsensitive, locale: .current)
            .removingAllNonAlphanumerics()
            .lowercased()
    }
    
    public func createUrl(song title: String, artist: String) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "azlyrics.com"
        components.path = "/lyrics/\(fixParameter(artist))/\(fixParameter(title))"
        
        return components.url?.appendingPathExtension("html")
    }
    
    public func extractLyrics(fromHTML html: String) -> String? {
        do {
            // Replacing <br> tag manually because Soup would just remove them and all text would be missing spaces.
            let newline = "__newline "
            let doc = try SwiftSoup.parse(html.replacingOccurrences(of: "<br>", with: newline))
            guard let element = try doc.getAllElements()
                    .filter ({ $0.tagName() == "div" })
                    .first(where: { element in
                try element.className().isEmpty && element.id().isEmpty
            }) else { return nil }
            
            let text = try element.text()
                .replacingOccurrences(of: newline, with: "\n")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            
            if text.isEmpty {
                return nil
            }
            return text
        } catch {
            print("*** AZLyrics parsing error: \(error)")
        }
        return nil
    }
}
