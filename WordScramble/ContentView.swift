//
//  ContentView.swift
//  WordScramble
//
//  Created by Maurício Costa on 11/01/23.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    @State private var currentScore = 0
    @State private var bestScore = 0
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count > 0 else { return }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can't spell that word from '\(rootWord)'!")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
            return
        }
        
        guard isShort(word: answer) else {
            wordError(title: "Word too short", message: "You can come up with a word longer than that!")
            return
        }
        
        guard isSame(word: answer) else {
            wordError(title: "Word is the same as root", message: "That's too easy. At least change the word!")
            return
        }

        withAnimation {
            usedWords.insert(answer, at: 0)
        }
        newWord = ""
    }
    
    func startGame() {
        // 1. Find the URL for start.txt in our app bundle
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            // 2. Load start.txt into a string
            if let startWords = try? String(contentsOf: startWordsURL) {
                // 3. Split the string up into an array of strings, splitting on line breaks
                let allWords = startWords.components(separatedBy: "\n")
                
                // 4. Pick one random word, or use "silkworm" as a sensible default
                rootWord = allWords.randomElement() ?? "silkworm"
                
                // If we are here everything has worked, so we can exit
                return
            }
        }
        
        // If were are *here* then there was a problem – trigger a crash and report the error
        fatalError("Could not load start.txt from bundle.")
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }
    
    func isShort(word: String) -> Bool {
        if word.count < 3 {
            return false
        }
        return true
    }
    func isSame(word:String) -> Bool {
        !(word.count == rootWord.count && word == rootWord)
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
    func calculateScore() {
        for word in usedWords {
            for _ in word {
                currentScore += 1
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    TextField("Write your word", text: $newWord).textInputAutocapitalization(.never)
                    List(usedWords, id: \.self) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel("\(word), \(word.count) letters")
                    }
                }
                Section {
                    VStack(alignment: .center) {
                        HStack {
                            Text("Score: \(currentScore)")
                            Text("Best: \(bestScore)")
                        }
                    }
                }
            }.frame(maxHeight: .infinity, alignment: .bottom)
                .navigationTitle(rootWord).toolbar{Button("New Word", action: startGame)
                }
        }
        .onSubmit {
            addNewWord()
            calculateScore()
        }
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showingError) {
                Button("OK", role: .cancel) { }
                } message: {
                Text(errorMessage)
                }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
