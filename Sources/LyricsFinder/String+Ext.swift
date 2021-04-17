//
//  String+Ext.swift
//  LyricsGrabber
//
//  Created by Adam Wienconek on 02/03/2021.
//

import Foundation
import UIKit

extension String {
    func removingAllNonAlphanumerics() -> String {
        let legalCharacters = CharacterSet.alphanumerics
        return components(separatedBy: legalCharacters.inverted).joined()
    }
    
    var removingSpecialCharacter: String {
        return components(separatedBy: CharacterSet.symbols).joined(separator: "")
    }
    
    func replacingOccurences(inSet set: CharacterSet, with replacementString: String) -> String {
        let c = String(self.unicodeScalars.filter { scalar in
            set.contains(scalar)
        })
        
        var replaced = self
        for replacement in c {
            replaced = replaced.replacingOccurrences(of: String(replacement), with: replacementString)
        }
        
        return replaced
    }
    
    func appendingProviderAttribution(provider: LyricsFinderProtocol, url: URL) -> NSAttributedString {
        let text = NSMutableAttributedString(string: self)
        
        let attributionText = "\n\nLyrics provided by\n\(provider.domainName)"
        let attributedText = NSAttributedString(string: attributionText, attributes: [.link: url])
        
        text.append(attributedText)
        return text
    }
}
