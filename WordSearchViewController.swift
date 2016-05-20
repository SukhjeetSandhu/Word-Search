//
//  WordSearchViewController.swift
//  Word Search
//
//  Created by sukhjeet singh sandhu on 25/04/16.
//  Copyright © 2016 sukhjeet singh sandhu. All rights reserved.
//

import UIKit

class WordSearchViewController: UIViewController {
    
    private var category: String!
    private var difficulty: Difficulty!
    
    @IBOutlet weak var categoryView: UIView!
    @IBOutlet weak var buttonToChangeCategory: UIButton!
    @IBOutlet weak var hintSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(categoryView)
        category = categoryType[0]
        difficulty = .Easy
        GameData.writeRecordsPlistToDocDir()
        GameData.writeAllRecordsFiles()
    }
    
    @IBAction func difficultyChanged(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0 :
            difficulty = .Easy
        case 1 :
            difficulty = .Medium
        case 2 :
            difficulty = .Hard
        default :
            fatalError("you are not setting difficulty for this case")
        }
    }
    
    @IBAction func buttonPressed(sender: UIButton) {
        let pickerView = UIPickerView()
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        pickerView.backgroundColor = view.backgroundColor
        categoryView.addSubview(pickerView)

        categoryView.addConstraint(NSLayoutConstraint(item: pickerView, attribute: .CenterX, relatedBy: .Equal, toItem: categoryView, attribute: .CenterX, multiplier: 1.0, constant: 1.0))
        categoryView.addConstraint(NSLayoutConstraint(item: pickerView, attribute: .CenterY, relatedBy: .Equal, toItem: categoryView, attribute: .CenterY, multiplier: 1.0, constant: 1.0))
        categoryView.addConstraint(NSLayoutConstraint(item: pickerView, attribute: .Leading, relatedBy: .Equal, toItem: categoryView, attribute: .Leading, multiplier: 1.0, constant: 1.0))
        categoryView.addConstraint(NSLayoutConstraint(item: pickerView, attribute: .Trailing, relatedBy: .Equal, toItem: categoryView, attribute: .Trailing, multiplier: 1.0, constant: 1.0))
        pickerView.delegate = self
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "play game" {
            if let gameViewController = segue.destinationViewController as? GameViewController {
                gameViewController.category = category
                gameViewController.difficulty = difficulty
                if hintSwitch.on {
                    gameViewController.showHint = true
                } else {
                    gameViewController.showHint = false
                }
            } else {
                let alert = UIAlertController(title: "OOPS!", message: "Can't go to the game Screen", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {(alert: UIAlertAction!) in exit(0)}))
                self.presentViewController(alert, animated: true, completion: nil)
                fatalError("Destination viewController is not same as you are expecting")
            }
        }
    }
}

extension WordSearchViewController: UIPickerViewDataSource {
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categoryType.count
    }
}

extension WordSearchViewController: UIPickerViewDelegate {
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categoryType[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        buttonToChangeCategory.setTitle(categoryType[row], forState: .Normal)
        pickerView.removeFromSuperview()
        category = categoryType[row]
    }
}
