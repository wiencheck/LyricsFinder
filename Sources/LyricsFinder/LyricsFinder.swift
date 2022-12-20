//
//  LyricsFinder.swift
//  LyricsGrabber
//
//  Created by Adam Wienconek on 02/03/2021.
//

import Foundation

public class LyricsFinder {
    
    public static var preferredLocale = Locale.current
    
    public static var provideAttribution = true
    
    private static var dataTask: URLSessionTask? {
        willSet { dataTask?.cancel() }
        didSet { dataTask?.resume() }
    }
    
    private static var availableProviders: [LyricsFinderProtocol] {[
            AZLyricsFinder(),
            MetroLyricsFinder(),
            TekstowoFinder()
    ]}
    
    public class func cancelCurrentSearchTask() {
        dataTask?.cancel()
    }
    
    public class func fetchLyrics(song title: String, artist: String, completion: @escaping (NSAttributedString?) -> Void) {
        let providers = availableProviders
            .sorted(by: {
                if $0.localeIdentifier == preferredLocale.languageCode {
                    return true
                }
                if $1.localeIdentifier == preferredLocale.languageCode {
                    return false
                }
                return false
            })
        
        func fetchLyrics(withProviderAtIndex index: Int) {
            if index >= providers.count {
                completion(nil)
                return
            }
            
            let provider = providers[index]
            self.fetchLyrics(song: title, artist: artist, usingProvider: provider, completion: { url, lyrics in
                guard let lyrics = lyrics else {
                    fetchLyrics(withProviderAtIndex: index + 1)
                    return
                }
                let attributedLyrics: NSAttributedString
                if provideAttribution {
                    attributedLyrics = lyrics.appendingProviderAttribution(provider: provider, url: url)
                } else {
                    attributedLyrics = NSAttributedString(string: lyrics)
                }
                completion(attributedLyrics)
            })
        }
        
        fetchLyrics(withProviderAtIndex: 0)
    }
    
    @available(*, unavailable)
    init() {}
    
}
    
private extension LyricsFinder {
    
    class func fetchLyrics(song title: String, artist: String, usingProvider provider: LyricsFinderProtocol, completion: @escaping (URL, String?) -> Void) {
        guard let url = provider.createUrl(song: title, artist: artist) else {
            return
        }
        let request = URLRequest(url: url, timeoutInterval: 1)
        
        dataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(url, nil)
                print(error)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 200 else {
                completion(url, nil)
                return
            }
            guard let data = data,
                  let htmlString = String(data: data, encoding: .utf8) else {
                completion(url, nil)
                return
            }
            let lyrics = provider.extractLyrics(fromHTML: htmlString)
            completion(url, lyrics)
        }
    }
    
}
