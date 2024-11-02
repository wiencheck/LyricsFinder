//
//  LyricsFinderProtocol.swift
//  LyricsGrabber
//
//  Created by Adam Wienconek on 02/03/2021.
//

import Foundation

public protocol LyricsFinderProtocol {
    func makeURL(for song: SongInfo) -> URL
    func extractLyrics(fromHTML html: String) -> String?
    
    var localeIdentifier: String { get }
    
    /// Name of the domain, used for attribution link.
    var domainName: String { get }
}
