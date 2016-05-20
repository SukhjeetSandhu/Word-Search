//
//  ColorUtil.swift
//  Word Search
//
//  Created by sukhjeet singh sandhu on 25/05/16.
//  Copyright © 2016 sukhjeet singh sandhu. All rights reserved.
//

import UIKit

extension UIColor {
     static func random() -> UIColor {
        let colors: [UIColor] = [.magentaColor(), .redColor(), .blueColor(), .purpleColor(), .orangeColor()]
        let randomIndex = Int(arc4random_uniform(UInt32(colors.count)))
        return colors[randomIndex]
    }
}
