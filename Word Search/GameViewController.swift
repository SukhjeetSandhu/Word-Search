//
//  GameViewController.swift
//  Word Search
//
//  Created by sukhjeet singh sandhu on 25/04/16.
//  Copyright © 2016 sukhjeet singh sandhu. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {
    
    //MARK: Expected Input
    var showHint: Bool = true
    var category: String!
    var difficulty: Difficulty!
    
    //MARK: States
    private var minute = 0                                              //minutes for timer
    private var second = 0                                              //seconds for timer
    private var rowOfFirstSelectedButton: Int?                          //to verify that next button is in same row
    private var columnOfFirstSelectedButton: Int?                       //to verify that next button is in same column
    private var buttonColor = UIColor()
    private var selectedWord: String?                                   //the word which we are selecting by panning over the buttons
    private var words: [String] = []                                    //list of words to be guessed
    private var tiles: [Tile] = []
    private var timer = NSTimer()                                       //to keep track of the time
    
    //MARK: UI properties
    private var selectedButtons: [Button] = []                        //to change the color of buttons that are selected
    private var previousSelectedButtons: [Button] = []                //to keep track of previous selected buttons to change background
    private var currentColor: UIColor!                                  //to keep track of the color of previous selected button
    private var buttonsForCharacters: [Button] = []                 //list of all the buttons in game
    private var wordLabels: [UILabel] = []                              //list of labels to display the words
    private let buttonsView = UIView()                                  //the view in which buttons reside
    private let wordsView = UIView()                                    // the view in which words reside
    private let gameView = UIView()                                     //view which contains buttonsView and wordsView
    
    //MARK: Data
    private var game: Game!                                             //object of game class
    
    //MARK: outlets
    @IBOutlet weak var pauseMessage: UILabel!
    
    //MARK: VC LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        game = Game(category: category, difficulty: difficulty)
        addViews()
        
        let (tiles, words) = game.generateBoardAndWords()
        self.words = words
        self.tiles = tiles
        
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(setTimer), userInfo: nil, repeats: true)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Pause, target: self, action: #selector(pauseGame))
        pauseMessage.hidden = true
        
        if showHint  {
            createLabels()
        } else {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints  = false
            label.text = "You Are On Your Own"
            label.font = label.font.fontWithSize(25)
            label.textColor = UIColor.blackColor()
            label.textAlignment = .Center
            wordsView.addSubview(label)
            
            wordsView.addConstraint(NSLayoutConstraint(item: label, attribute: .CenterX, relatedBy: .Equal, toItem: wordsView, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
            wordsView.addConstraint(NSLayoutConstraint(item: label, attribute: .CenterY, relatedBy: .Equal, toItem: wordsView, attribute: .CenterY, multiplier: 1.0, constant: 0.0))
        }
        
        createButtons()
        buttonsView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(selectWord)))
    }
    
    //MARK: Create UI Elements
    private func addViews() {
        
        gameView.translatesAutoresizingMaskIntoConstraints = false
        wordsView.translatesAutoresizingMaskIntoConstraints = false
        buttonsView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(gameView)
        view.addConstraint(NSLayoutConstraint(item: gameView, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1.0, constant: (navigationController?.navigationBar.frame.height)! + UIApplication.sharedApplication().statusBarFrame.height))
        view.addConstraint(NSLayoutConstraint(item: gameView, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1.0, constant: 1.0))
        view.addConstraint(NSLayoutConstraint(item: gameView, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .Leading, multiplier: 1.0, constant: 1.0))
        view.addConstraint(NSLayoutConstraint(item: gameView, attribute: .Trailing, relatedBy: .Equal, toItem: view, attribute: .Trailing, multiplier: 1.0, constant: 1.0))
        
        gameView.addSubview(buttonsView)
        gameView.addSubview(wordsView)
        wordsView.backgroundColor = UIColor(red: 234/255, green: 216/255, blue: 196/255, alpha: 1.0)
        
        gameView.addConstraint(NSLayoutConstraint(item: buttonsView, attribute: .Top, relatedBy: .Equal, toItem: gameView, attribute: .Top, multiplier: 1.0, constant: 0.0))
        gameView.addConstraint(NSLayoutConstraint(item: buttonsView, attribute: .Leading, relatedBy: .Equal, toItem: gameView, attribute: .Leading, multiplier: 1.0, constant: 0.0))
        gameView.addConstraint(NSLayoutConstraint(item: buttonsView, attribute: .Trailing, relatedBy: .Equal, toItem: gameView, attribute: .Trailing, multiplier: 1.0, constant: 0.0))
        
        gameView.addConstraint(NSLayoutConstraint(item: wordsView, attribute: .Bottom, relatedBy: .Equal, toItem: gameView, attribute: .Bottom, multiplier: 1.0, constant: 0.0))
        gameView.addConstraint(NSLayoutConstraint(item: wordsView, attribute: .Leading, relatedBy: .Equal, toItem: gameView, attribute: .Leading, multiplier: 1.0, constant: 0.0))
        gameView.addConstraint(NSLayoutConstraint(item: wordsView, attribute: .Trailing, relatedBy: .Equal, toItem: gameView, attribute: .Trailing, multiplier: 1.0, constant: 0.0))
        gameView.addConstraint(NSLayoutConstraint(item: wordsView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 72.0))
        gameView.addConstraint(NSLayoutConstraint(item: wordsView, attribute: .Top, relatedBy: .Equal, toItem: buttonsView, attribute: .Bottom, multiplier: 1.0, constant: 1.0))
        
        view.layoutIfNeeded()
    }
    
    private func createButtons() {
        
        let buttonSize = CGSize(width: buttonsView.frame.width / CGFloat(difficulty.noOfColumns + 1), height: buttonsView.frame.size.height / (CGFloat(difficulty.noOfRows) + 1))
        let gapInXPosOfButtons = buttonSize.width / CGFloat(difficulty.noOfColumns + 1)
        let gapInYPosOfButtons = buttonSize.width / CGFloat(difficulty.noOfRows + 1)
        
        for tile in tiles {
            let button = Button()
            button.translatesAutoresizingMaskIntoConstraints = false
            button.backgroundColor = UIColor.grayColor()
            
            buttonsView.addSubview(button)
            
            buttonsView.addConstraint(NSLayoutConstraint(item: button, attribute: .Leading, relatedBy: .Equal, toItem: buttonsView, attribute: .Leading, multiplier: 1.0, constant: (CGFloat(tile.index.1) * buttonSize.width) + (CGFloat(tile.index.1 + 1) * (gapInXPosOfButtons))))
            
            buttonsView.addConstraint(NSLayoutConstraint(item: button, attribute: .Top, relatedBy: .Equal, toItem: buttonsView, attribute: .Top, multiplier: 1.0, constant: (CGFloat(tile.index.0) * buttonSize.height) + (CGFloat(tile.index.0 + 1) * (gapInYPosOfButtons))))
            
            buttonsView.addConstraint(NSLayoutConstraint(item: button, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant:  buttonsView.frame.width / CGFloat(difficulty.noOfColumns + 1)))
            
            buttonsView.addConstraint(NSLayoutConstraint(item: button, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant:  buttonsView.frame.size.height / (CGFloat(difficulty.noOfRows) + 1)))
            
            button.setTitle(tile.character, forState: .Normal)
            button.row = tile.index.0
            button.column = tile.index.1
            buttonsForCharacters.append(button)
        }
    }
    
    private func createLabels() {
        
        let maxLabelSize = CGSize(width: wordsView.frame.width / CGFloat(difficulty.noOfColumnsForWordLabels), height: wordsView.frame.height / CGFloat(difficulty.noOfRowsForWordLabels + 1))
        var wordIndex = 0
        for row in 0..<difficulty.noOfRowsForWordLabels {
            for column in 0..<difficulty.noOfColumnsForWordLabels {
                let label = UILabel()
                label.translatesAutoresizingMaskIntoConstraints = false
                label.text = words[wordIndex]
                label.font = label.font.fontWithSize(12)
                label.textAlignment = .Center
                label.textColor = UIColor.blackColor()
                label.adjustsFontSizeToFitWidth = true
                wordsView.addSubview(label)
                
                wordsView.addConstraint(NSLayoutConstraint(item: label, attribute: .Top, relatedBy: .Equal, toItem: wordsView, attribute: .Top, multiplier: 1.0, constant: (CGFloat(row + 1) * (maxLabelSize.height / CGFloat(difficulty.noOfRowsForWordLabels + 1))) + CGFloat(row) * (maxLabelSize.height)))
                
                wordsView.addConstraint(NSLayoutConstraint(item: label, attribute: .Leading, relatedBy: .Equal, toItem: wordsView, attribute: .Leading, multiplier: 1.0, constant: (CGFloat(column) * (maxLabelSize.width)) + 10 ))

                wordLabels.append(label)
                wordsView.addSubview(label)
                wordIndex += 1
            }
        }
    }
    
    //MARK: Helper Methods
    private func getColorFor(randomNumber num: Int) -> UIColor {
        switch num {
        case 0 : return UIColor.magentaColor()
        case 1 : return UIColor.redColor()
        case 2 : return UIColor.blueColor()
        case 3 : return UIColor.purpleColor()
        default : return UIColor.orangeColor()
        }
    }
    
    private func buttonHidden(hidden: Bool) {
        for button in buttonsForCharacters {
            button.hidden = hidden
        }
    }
    
    private func changeButtonsBackground() {
        for button in previousSelectedButtons {
            button.backgroundColor = .grayColor()
        }
        previousSelectedButtons = []
    }
    
    //MARK: Verify Selected Words
    private func checkWord(word: String) {
        selectedWord = nil
        if !word.isEmpty {
            for index in 0..<words.count {
                if words[index] == word {
                    if !wordLabels.isEmpty {
                        wordLabels[index].text = ""
                    }
                    words[index] = ""
                    checkList()
                    selectedButtons.removeAll()
                    previousSelectedButtons.removeAll()
                    return
                }
            }
        }
        for button in selectedButtons {
            button.backgroundColor = .grayColor()
        }
        changeButtonsBackground()
        selectedButtons.removeAll()
    }
    
    private func checkList() {
        var win = true
        for word in words {
            if !word.isEmpty {
                win = false
                break
            }
        }
        if win {
            buttonHidden(true)
            pauseMessage.text = "You Win!!"
            pauseMessage.hidden = false
            timer.invalidate()
            navigationItem.rightBarButtonItem = nil
            if let title = self.title {
                let currentScore = title
                let fileName = "\(difficulty)"
                if !GameData.updateRecords(currentScore, fileName: fileName) {
                    let alert = UIAlertController(title: "OOPS!", message: "Can't Update Records", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {(alert: UIAlertAction!) in exit(0)}))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    private func checkButtonLocation(location: CGPoint, completion: (Int, Int) -> Void ) {
        if let button = buttonsView.hitTest(location, withEvent: nil) as? Button {
            if let row = button.row, column = button.column {
                completion(row, column)
            }
        }
        
    }
    
    //MARK: selection
    private func selectButtons (row: Int, column: Int, color: UIColor) {
        for button in buttonsForCharacters {
            if button.row == row && button.column == column {
                if button.backgroundColor == UIColor.grayColor() {
                    button.backgroundColor = color
                    
                    if let letter = button.titleLabel?.text {
                        selectedButtons.append(button)
                        previousSelectedButtons.append(button)
                        if let selectedWord = selectedWord {
                            self.selectedWord = selectedWord + letter
                        } else {
                            selectedWord = letter
                        }
                    }
                }
                break
            }
        }
    }
    
    func selectWord(sender: UIPanGestureRecognizer) {
        let location = sender.locationInView(buttonsView)
        switch sender.state {
        case .Began :
            
            // will select the first button
            buttonColor = UIColor.random()
            checkButtonLocation(location, completion: { (row, column) in
                self.selectButtons(row, column: column, color: self.buttonColor)
                self.rowOfFirstSelectedButton = row
                self.columnOfFirstSelectedButton = column
            })
        
        case .Changed :
            
            // will check whether the next button in the same row or same column or in the diagonal
            // if yes then will select them
            // will change the color of them
            // will store the titles of the buttons
            
            if let columnOfFirstSelectedButton = columnOfFirstSelectedButton, rowOfFirstSelectedButton = rowOfFirstSelectedButton {
                checkButtonLocation(location, completion: { (row, column) in
                    for button in self.selectedButtons {
                        self.currentColor = button.backgroundColor
                        button.backgroundColor = .grayColor()
                    }
                    self.selectedButtons = []
                    self.selectedWord = nil
                    
                    if (row == rowOfFirstSelectedButton) && (column > columnOfFirstSelectedButton) {
                        self.changeButtonsBackground()
                        for currentColumn in columnOfFirstSelectedButton...column {
                            self.selectButtons(row, column: currentColumn, color: self.buttonColor)
                        }
                    }
                    else if (row == rowOfFirstSelectedButton) && (column < columnOfFirstSelectedButton) {
                        self.changeButtonsBackground()
                        for currentColumn in (column...columnOfFirstSelectedButton).reverse() {
                            self.selectButtons(row, column: currentColumn, color: self.buttonColor)
                        }
                    }
                    else if (column == columnOfFirstSelectedButton) && (row > rowOfFirstSelectedButton) {
                        self.changeButtonsBackground()
                        for currentRow in rowOfFirstSelectedButton...row {
                            self.selectButtons(currentRow, column: column, color: self.buttonColor)
                        }
                    }
                    else if (column == columnOfFirstSelectedButton) && (row < rowOfFirstSelectedButton) {
                        self.changeButtonsBackground()
                        for currentRow in (row...rowOfFirstSelectedButton).reverse() {
                            self.selectButtons(currentRow, column: column, color: self.buttonColor)
                        }
                    }
                    else if (abs(row - rowOfFirstSelectedButton) == abs(column - columnOfFirstSelectedButton)) {
                        self.changeButtonsBackground()
                        if (row > rowOfFirstSelectedButton) && (column > columnOfFirstSelectedButton) {
                            var currentColumn = columnOfFirstSelectedButton
                            for currntRow in rowOfFirstSelectedButton...row {
                                self.selectButtons(currntRow, column: currentColumn, color: self.buttonColor)
                                currentColumn += 1
                            }
                        }
                            
                        else if (row < rowOfFirstSelectedButton) && (column > columnOfFirstSelectedButton) {
                            var currentColumn = columnOfFirstSelectedButton
                            for currentRow in (row...rowOfFirstSelectedButton).reverse() {
                                self.selectButtons(currentRow, column: currentColumn, color: self.buttonColor)
                                currentColumn += 1
                            }
                        }
                            
                        else if (row > rowOfFirstSelectedButton) && (column < columnOfFirstSelectedButton) {
                            var currentColumn = columnOfFirstSelectedButton
                            for currentRow in rowOfFirstSelectedButton...row {
                                self.selectButtons(currentRow, column: currentColumn, color: self.buttonColor)
                                currentColumn -= 1
                            }
                        }
                            
                        else if (row < self.rowOfFirstSelectedButton) && (column < self.columnOfFirstSelectedButton) {
                            var currentColumn = columnOfFirstSelectedButton
                            for currentRow in (row...rowOfFirstSelectedButton).reverse() {
                                self.selectButtons(currentRow, column: currentColumn, color: self.buttonColor)
                                currentColumn -= 1
                            }
                        }
                    } else {
                        for button in self.previousSelectedButtons {
                            button.backgroundColor = self.currentColor
                        }
                    }
                })
            }
            
        case .Ended:
            
            // will check whether the selected word matches to any word in words Array
            
            rowOfFirstSelectedButton = nil
            columnOfFirstSelectedButton = nil
            if let selectedWord = selectedWord {
                checkWord(selectedWord)
            }

        default :
            break
        }
    }
    
    //MARK: Timer Functions
    func pauseGame() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Play, target: self, action: #selector(resumeGame))
        timer.invalidate()
        buttonHidden(true)
        pauseMessage.text = "Game Paused!!"
        pauseMessage.hidden = false
    }
    
    func resumeGame() {
        pauseMessage.hidden = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Pause, target: self, action: #selector(pauseGame))
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(setTimer), userInfo: nil, repeats: true)
        buttonHidden(false)
    }
    
    func setTimer() {
        second += 1
        if second >= 60 {
            minute += 1
            second = 0
        }
        self.title = String(format: "%.2d:%.2d",minute,second)
    }
}
