//
//  RecordsCollectionViewController.swift
//  Word Search
//
//  Created by sukhjeet singh sandhu on 09/05/16.
//  Copyright © 2016 sukhjeet singh sandhu. All rights reserved.
//

import UIKit

class RecordsCollectionViewController: UICollectionViewController {
    
    private let reuseIdentifier = "Record Cell"
    private let headerIdentifier = "Difficulty Level"
    private var easyRecords: [String] = GameData.readRecordsFiles("\(Difficulty.Easy)")
    private var mediumRecords: [String] = GameData.readRecordsFiles("\(Difficulty.Medium)")
    private var hardRecords: [String] = GameData.readRecordsFiles("\(Difficulty.Hard)")

    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    }

    // MARK: UICollectionViewDataSource
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 3
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return easyRecords.count
        case 1:
            return mediumRecords.count
        case 2:
            return hardRecords.count
        default:
            fatalError("Can't find records for this section")
        }
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath)
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        cell.addSubview(label)
        
        cell.addConstraint(NSLayoutConstraint(item: label, attribute: .CenterX, relatedBy: .Equal, toItem: cell, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
        cell.addConstraint(NSLayoutConstraint(item: label, attribute: .CenterY, relatedBy: .Equal, toItem: cell, attribute: .CenterY, multiplier: 1.0, constant: 0.0))
        label.textAlignment = .Center
        label.textColor = .whiteColor()
        label.font = label.font.fontWithSize(20)
        cell.backgroundColor = .grayColor()
            
        if indexPath.section == 0 && easyRecords[indexPath.row] != "" {
            label.text = easyRecords[indexPath.row]
        } else if indexPath.section == 1  && mediumRecords[indexPath.row] != "" {
            label.text = mediumRecords[indexPath.row]
        } else if indexPath.section == 2 && hardRecords[indexPath.row] != ""{
            label.text = hardRecords[indexPath.row]
        }
    
        return cell
    }

    // MARK: UICollectionViewDelegate
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionElementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: headerIdentifier, forIndexPath: indexPath)
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.textColor = .blackColor()
            headerView.addSubview(label)
            headerView.addConstraint(NSLayoutConstraint(item: label, attribute: .Leading, relatedBy: .Equal, toItem: headerView, attribute: .Leading, multiplier: 1.0, constant: 8.0))
            label.font = label.font.fontWithSize(25)
    
            if indexPath.section == 0 && !easyRecords.isEmpty {
                label.text = "\(Difficulty.Easy)"
            } else if indexPath.section == 1 && !mediumRecords.isEmpty {
                label.text = "\(Difficulty.Medium)"
            } else if !hardRecords.isEmpty && indexPath.section == 2 {
                label.text = "\(Difficulty.Hard)"
            }
            return headerView
        } else {
            fatalError("Unexpected Element Kind")
        }
    }
}
