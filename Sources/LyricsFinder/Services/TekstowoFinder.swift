//
//  File.swift
//  
//
//  Created by Adam Wienconek on 03/03/2021.
//

import Foundation

public struct TekstowoFinder: LyricsFinderProtocol {
    var localeIdentifier: String {
        return "pl"
    }
    
    var domainName: String {
        return "Tekstowo"
    }
    
    private func fixParameter(_ parameter: String) -> String {
        let set = CharacterSet.punctuationCharacters.union(.whitespaces)
        return parameter
            .folding(options: .diacriticInsensitive, locale: .current)
            .replacingOccurences(inSet: set, with: "_")
            .lowercased()
    }
    
    func createUrl(song title: String, artist: String) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "tekstowo.pl"
        components.path = "/piosenka,\(fixParameter(artist)),\(fixParameter(title))"
        return components.url?.appendingPathExtension("html")
    }
    
    func extractLyrics(fromHTML html: String) -> String? {
        let startText = "Tekst piosenki:</h2>"
        let endText = "<p>&nbsp;</p>"
        
        guard let startIndex = html.range(of: startText)?.upperBound,
              let endIndex = html.range(of: endText)?.lowerBound else {
            return nil
        }
        
        let text = String(html[startIndex ..< endIndex])
        return text
            .replacingOccurrences(of: "<br />", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
