//
//  LyricsFinderProtocol.swift
//  LyricsGrabber
//
//  Created by Adam Wienconek on 02/03/2021.
//

import Foundation

protocol LyricsFinderProtocol {
    func createUrl(song title: String, artist: String) -> URL?
    func extractLyrics(fromHTML html: String) -> String?
    
    var localeIdentifier: String { get }
    
    /// Name of the domain, used for attribution link.
    var domainName: String { get }
}
