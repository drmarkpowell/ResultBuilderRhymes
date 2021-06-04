//
//  ContentView.swift
//  Shared
//
//  Created by Mark Powell on 6/4/21.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var rhymeViewModel = RhymesViewModel()
    @State private var wordToRhyme: String = ""

    var body: some View {
        TextField("Word to rhyme:", text: $wordToRhyme) { _ in
            rhymeViewModel.query(word: wordToRhyme)
        }

        multipleTexts()
            .padding()
    }

    @TextBuilder func multipleTexts() -> Text {
        if rhymeViewModel.rhymingResults.isEmpty {
            "Enter a word to find rhymes for"
        } else {
            "Rhymes for \(wordToRhyme) are "
        }
        for rhyme in rhymeViewModel.rhymingResults {
            rhyme
        }
    }
}

@resultBuilder
struct TextBuilder {
    static func buildBlock(_ parts: Text...) -> Text {
        parts.reduce(Text(""), { t1, t2 in
            t1 + t2
        })
    }

    static func buildArray(_ components: [Text]) -> Text {
        components.reduce(Text(""), { t1, t2 in
            t1 + Text(" ") + t2
        })
    }

    static func buildEither(first component: Text) -> Text {
        component
    }

    static func buildEither(second component: Text) -> Text {
        component
    }

    static func buildExpression(_ expresssion: String) -> Text {
        Text(expresssion)
    }

    static func buildExpression(_ expression: Rhyme) -> Text {
        Text(expression.word).font(fontForScore(score: expression.score))
    }

    static func fontForScore(score: Int?) -> Font? {
        if let score = score {
            if score > 200 {
                return Font.largeTitle
            } else {
                return Font.body
            }
        }
        return Font.footnote
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

class RhymesViewModel: ObservableObject {
    @Published var rhymingResults: [Rhyme] = []

    func query(word: String) {
        let url = URL(string: "https://api.datamuse.com/words?rel_rhy=\(word)")!
        URLSession.shared.dataTask(with: url) { data, result, error in
            if let data = data {
                DispatchQueue.main.async {
                    do {
                        self.rhymingResults = try JSONDecoder().decode([Rhyme].self, from: data)
                    } catch let error {
                        print("\(error.localizedDescription)")
                    }
                }
            }
        }.resume()
    }
}

struct Rhyme: Codable {
    var word: String
    var score: Int?
    var numSyllables: Int
}

