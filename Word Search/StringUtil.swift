//
//  StringUtil.swift
//  Word Search
//
//  Created by sukhjeet singh sandhu on 29/04/16.
//  Copyright © 2016 sukhjeet singh sandhu. All rights reserved.
//

import Foundation

extension String {
    subscript(i: Int) -> String {
        return String(self[self.startIndex.advancedBy(i)])
    }
}
