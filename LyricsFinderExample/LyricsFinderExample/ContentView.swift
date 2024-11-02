//
//  ContentView.swift
//  LyricsFinderExample
//
//  Created by Adam Wienconek on 23/10/2024.
//

import SwiftUI
import LyricsFinder

struct ContentView: View {
    
    @State
    private var artist: String = ""
    
    @State
    private var title: String = ""
    
    @State
    private var lyrics: String?
    
    var body: some View {
        VStack {
            ScrollViewReader { reader in
                ScrollView {
                    VStack(alignment: .leading) {
                        if let lyrics {
                            Text(lyrics)
                        }
                        else {
                            Text("Hello, world!")
                        }
                    }
                }
            }
            Spacer()
            
            Form {
                TextField(
                    "Artist name",
                    text: $artist
                )
                TextField(
                    "Song title",
                    text: $title
                )
            }
            Button(
                "Search",
                action: {
                    searchForLyrics()
                }
            )
        }
        .padding()
    }
    
    private func searchForLyrics() {
        Task {
            let result = try? await LyricsFinder.searchLyrics(
                with: (title, artist),
                using: GeniusLyricsFinder()
            )
            print(result)
            lyrics = result
        }
    }
    
}

#Preview {
    ContentView()
}
