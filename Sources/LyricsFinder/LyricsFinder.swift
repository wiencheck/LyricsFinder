//
//  LyricsFinder.swift
//  LyricsGrabber
//
//  Created by Adam Wienconek on 02/03/2021.
//

import Foundation

public struct LyricsFinder {
    private init() {}
    
    public static var preferredLocale = Locale.current
    
    public static var saveLyrics = false
    
    public static var provideAttribution = true
    
    private static var dataTask: URLSessionTask? {
        willSet {
            dataTask?.cancel()
        } didSet {
            dataTask?.resume()
        }
    }
    
    private static var availableProviders: [LyricsFinderProtocol] {
        return [
            AZLyricsFinder(),
            MetroLyricsFinder(),
            TekstowoFinder()
        ]
    }
    
    public static func cancelCurrentSearchTask() {
        dataTask?.cancel()
    }
    
    public static func fetchLyrics(song title: String, artist: String, completion: @escaping (NSAttributedString?) -> Void) {
        if saveLyrics, let lyrics = readLyrics(song: title, artist: artist) {
            completion(lyrics)
            return
        }
        
        let providers = availableProviders
            .shuffled()
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
                saveLyrics(song: title, artist: artist, lyrics: attributedLyrics)
                completion(attributedLyrics)
            })
        }
        
        fetchLyrics(withProviderAtIndex: 0)
    }
    
    private static func fetchLyrics(song title: String, artist: String, usingProvider provider: LyricsFinderProtocol, completion: @escaping (URL, String?) -> Void) {
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

private extension LyricsFinder {
    private static var userDefaultsDictionaryKey: String {
        return "LYRICS_FINDER_SAVED_RESULTS"
    }
    
    private static var defaults: UserDefaults {
        return .standard
    }
    
    private static func generateDictionaryKey(song title: String, artist: String) -> String {
        let fixedTitle = title
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .removingAllNonAlphanumerics()
            .lowercased()
        
        let fixedArtist = artist
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .removingAllNonAlphanumerics()
            .lowercased()
        
        return "\(fixedArtist)-\(fixedTitle)"
    }
    
    static func readLyrics(song title: String, artist: String) -> NSAttributedString? {
        let key = generateDictionaryKey(song: title, artist: artist)
        guard let dictionary = UserDefaults.standard.dictionary(forKey: userDefaultsDictionaryKey) as? [String: Data],
              let data = dictionary[key] else {
            return nil
        }
        
        //return NSAttributedString(data: data, options: [:], documentAttributes: nil)
        return try? NSAttributedString(data: data, documentType: .rtf)
    }
    
    static func saveLyrics(song title: String, artist: String, lyrics: NSAttributedString) {
        let data = lyrics.data(.rtf)
        
        var dictionary = defaults.dictionary(forKey: userDefaultsDictionaryKey) as? [String: Data] ?? [:]
        
        let key = generateDictionaryKey(song: title, artist: artist)
        dictionary.updateValue(data, forKey: key)
        
        defaults.set(dictionary, forKey: userDefaultsDictionaryKey)
    }
}
