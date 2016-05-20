//
//  Game.swift
//  Word Search
//
//  Created by sukhjeet singh sandhu on 26/04/16.
//  Copyright © 2016 sukhjeet singh sandhu. All rights reserved.
//

import Foundation

var categoryType = ["Animals", "Body", "Cars", "Cities", "Fruits", "Space"]

enum Difficulty {
    case Easy
    case Medium
    case Hard
    
    private static let associatedValues = [
        Easy : (noOfRows: 10, noOfColumns: 7, noOfWords: 6, maxLengthOfWord: 6, noOfRowsForWordLabels: 2, noOfColumnsForWordLabels: 3),
        Medium : (noOfRows: 11, noOfColumns: 8, noOfWords: 9, maxLengthOfWord: 7, noOfRowsForWordLabels: 3, noOfColumnsForWordLabels: 3),
        Hard : (noOfRows: 13, noOfColumns: 9, noOfWords: 12, maxLengthOfWord: 9, noOfRowsForWordLabels: 3, noOfColumnsForWordLabels: 4)
    ]
    
    var noOfRows: Int {
        if let totalRows = Difficulty.associatedValues[self]?.noOfRows {
            return totalRows
        } else {
            fatalError("associated values for this case are not defined")
        }
    }
    
    var noOfColumns: Int {
        if let totalColumns = Difficulty.associatedValues[self]?.noOfColumns {
            return totalColumns
        } else {
            fatalError("associated values for this case are not defined")
        }
    }
    
    var noOfWords: Int {
        if let totalWords =  Difficulty.associatedValues[self]?.noOfWords {
            return totalWords
        } else {
            fatalError("associated values for this case are not defined")
        }
    }
    
    var maxLengthOfWord: Int {
        if let lengthOfWord = Difficulty.associatedValues[self]?.maxLengthOfWord {
            return lengthOfWord
        } else {
            fatalError("associated values for this case are not defined")
        }
    }
    
    var noOfRowsForWordLabels: Int {
        if let totalRowsForLabels = Difficulty.associatedValues[self]?.noOfRowsForWordLabels {
            return totalRowsForLabels
        } else {
            fatalError("associated values for this case are not defined")
        }
    }
    
    var noOfColumnsForWordLabels: Int {
        if let totalColumnsForLabels = Difficulty.associatedValues[self]?.noOfColumnsForWordLabels {
            return totalColumnsForLabels
        } else {
            fatalError("associated values for this case are not defined")
        }
    }
}

struct Tile {
    let character: String
    let index : (Int, Int)
}

struct Game {

    private let difficulty: Difficulty
    private let file: String
    
    init(category: String, difficulty: Difficulty) {
        
        file = category
        self.difficulty = difficulty
    }
    
    func generateBoardAndWords() -> ([Tile], [String]) {
        
        var words: [String] = []
        var tiles: [Tile] = []
        while words.count < difficulty.noOfWords {
            if let (sequence, word) = properSequenceToPlaceText(tiles) {
                if !words.contains(word) {
                    words.append(word)
                    tiles.appendContentsOf(createTilesWithText(sequence, word: word))
                }
            }
        }
        tiles.appendContentsOf(createRestOfTilesWithRandomText(tiles))
        return (tiles, words)
    }
    
    private func generateRandomWord() -> String {
        
        var word: String?
        let wordLines = GameData.readCategoryFiles(file)
        if !wordLines.isEmpty {
            word = wordLines[Int(arc4random_uniform(UInt32(wordLines.count)))]
        }
        
        if let word = word {
            if word.characters.count <= difficulty.maxLengthOfWord {
                return word
            }
            else {
                return generateRandomWord()
            }
        } else {
            return generateRandomWord()
        }
    }
    
    private func isValidInGame(sequence: [(Int, Int)], word: String, tiles: [Tile]) -> Bool {
        
        var countRightPlaces = 0
        var isTileExist = false
        for index in sequence {
            for tile in tiles {
                if tile.index == index {
                    isTileExist = true
                }
            }
            if !isTileExist {
                countRightPlaces += 1
            }
        }
        
        if countRightPlaces == word.characters.count {
            return true
        } else {return false }
    }
    
    private func properSequenceToPlaceText(tiles: [Tile]) -> ([(Int, Int)], String)? {
        
        //will check in every direction whether we can place the word or not
        //will append all the valid directions into sequences array
        //will select one random direction from sequences and will return it along with the word
        
        let tiles = tiles
        let word = generateRandomWord()
        let length = word.characters.count - 1
        let row = Int(arc4random() % uint(difficulty.noOfRows - 1))
        let column = Int(arc4random() % uint(difficulty.noOfColumns - 1))
        var sequenceForward = [(Int, Int)]()
        var sequenceBackward = [(Int, Int)]()
        var sequences = [[(Int, Int)]]()
        
        if (column - length) >= 0 {
            // will check in west direction
            
            for i in 0...length {
                sequenceForward.append((row, column - length + i))
                sequenceBackward.append((row, column - i))
            }
            if isValidInGame(sequenceBackward, word: word, tiles: tiles) {
                sequences.append(sequenceBackward)
                sequences.append(sequenceForward)
            }
            sequenceForward.removeAll()
            sequenceBackward.removeAll()
        }
        if (length + column) < difficulty.noOfColumns {
            // will check in east direction
            
            for i in 0...length {
                sequenceForward.append((row, column + length - i))
                sequenceBackward.append((row, column + i))
            }
            if isValidInGame(sequenceBackward, word: word, tiles: tiles) {
                sequences.append(sequenceBackward)
                sequences.append(sequenceForward)
            }
            sequenceForward.removeAll()
            sequenceBackward.removeAll()
        }
        if (row - length) >= 0 {
            //will check in North direction
            
            for i in 0...length {
                sequenceForward.append((row - i, column))
                sequenceBackward.append((row - length + i, column))
            }
            if isValidInGame(sequenceForward, word: word, tiles: tiles) {
                sequences.append(sequenceForward)
                sequences.append(sequenceBackward)
            }
            sequenceForward.removeAll()
            sequenceBackward.removeAll()
        }
        if (row + length) < difficulty.noOfRows {
            //will check in south direction
            
            for i in 0...length {
                sequenceBackward.append((row + i, column))
                sequenceForward.append((row + length - i, column))
            }
            if isValidInGame(sequenceBackward, word: word, tiles: tiles) {
                sequences.append(sequenceBackward)
                sequences.append(sequenceForward)
            }
            sequenceForward.removeAll()
            sequenceBackward.removeAll()
        }
        if (row - length) >= 0 && (column - length) >= 0 {
            //will check in NorthWest direction
            
            for i in 0...length {
                sequenceBackward.append((row - length + i, column - length + i))
                sequenceForward.append((row - i, column - i))
            }
            if isValidInGame(sequenceBackward, word: word, tiles: tiles) {
                sequences.append(sequenceBackward)
                sequences.append(sequenceForward)
            }
            sequenceForward.removeAll()
            sequenceBackward.removeAll()
        }
        if (row - length) >= 0 && (column + length) < difficulty.noOfColumns {
            //will check in NorthEast direction
            
            for i in 0...length {
                sequenceForward.append((row - i, column + i))
                sequenceBackward.append((row - length + i, column + length - i))
            }
            if isValidInGame(sequenceForward, word: word, tiles: tiles) {
                sequences.append(sequenceBackward)
                sequences.append(sequenceForward)
            }
            sequenceForward.removeAll()
            sequenceBackward.removeAll()
        }
        if (row + length) < difficulty.noOfRows && (column - length) >= 0 {
            //will check in SouthWest direction
            
            for i in 0...length {
                sequenceBackward.append((row + i, column - i))
                sequenceForward.append((row + length - i, column - length + i))
            }
            if isValidInGame(sequenceForward, word: word, tiles: tiles) {
                sequences.append(sequenceBackward)
                sequences.append(sequenceForward)
            }
            sequenceForward.removeAll()
            sequenceBackward.removeAll()
        }
        if (row + length) < difficulty.noOfRows && (column + length) < difficulty.noOfColumns {
            //will check in SouthEast direction
            
            for i in 0...length {
                sequenceBackward.append((row + i, column + i))
                sequenceForward.append((row + length - i, column + length - i))
            }
            if isValidInGame(sequenceForward, word: word, tiles: tiles) {
                sequences.append(sequenceBackward)
                sequences.append(sequenceForward)
                
            }
            sequenceForward.removeAll()
            sequenceBackward.removeAll()
        }
        
        if sequences.isEmpty {
            return nil
        }
        else {
            let randomIndex = Int(arc4random_uniform(UInt32((sequences.count - 1))))
            let properSequence = sequences[randomIndex]
            return (properSequence, word)
        }
    }
    
    private func createTilesWithText(sequence: [(Int, Int)], word: String) -> [Tile] {
        
        var tempTiles: [Tile] = []
        for (wordIndex, tileIndex) in sequence.enumerate() {
            let tile = Tile(character: word[wordIndex], index: tileIndex)
            tempTiles.append(tile)
        }
        return tempTiles
    }
    
    private func createRestOfTilesWithRandomText(tiles: [Tile]) -> [Tile] {
        
        var tempTiles: [Tile] = []
        for row in 0..<difficulty.noOfRows {
            for column in 0..<difficulty.noOfColumns {
                var isTileExist = false
                for tile in tiles {
                    if tile.index == (row, column) {
                        isTileExist = true
                    }
                }
                if !isTileExist {
                    let randomCharacter = String(UnicodeScalar(Int((arc4random() % 26) + 65 )))
                    let tile = Tile(character: randomCharacter, index: (row, column))
                    tempTiles.append(tile)
                }
            }
        }
        return tempTiles
    }
}
