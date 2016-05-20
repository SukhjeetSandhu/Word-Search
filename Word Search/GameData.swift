//
//  WriteIntoPlist.swift
//  Word Search
//
//  Created by sukhjeet singh sandhu on 02/05/16.
//  Copyright © 2016 sukhjeet singh sandhu. All rights reserved.
//

import Foundation

struct GameData {
    
    private  static let fileManager = NSFileManager.defaultManager()
    private static let pathToDocumentsFolder = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
    
    static func writeRecordsPlistToDocDir() {
        let fileName = "records"
        let filePath = pathToDocumentsFolder.stringByAppendingString("\(fileName).plist")
        if (!fileManager.fileExistsAtPath(filePath)) {
            do{
                if let pathForResource = NSBundle.mainBundle().pathForResource(fileName, ofType: "plist") {
                    try fileManager.copyItemAtPath(pathForResource, toPath: filePath)
                }
            } catch {
                fatalError("Items could not be copied")
            }
        }
    }
    
    static func writeRecordsFileToDocDir(fileName: String) {
        let filePath = pathToDocumentsFolder.stringByAppendingString(fileName)
        if (!fileManager.fileExistsAtPath(filePath)) {
            do{
                if let pathForResource = NSBundle.mainBundle().pathForResource(fileName, ofType: nil){
                    try fileManager.copyItemAtPath(pathForResource, toPath: filePath)
                }
            } catch {
                fatalError("Items could not be copied")
            }
        }
    }
    
    static func writeAllRecordsFiles() {
        let pathForRecords = pathToDocumentsFolder.stringByAppendingString("records.plist")
        if let contents = NSArray(contentsOfFile: pathForRecords) {
            for x in contents {
                writeRecordsFileToDocDir(x as! String)
            }
        }
    }
    
    static func readCategoryFiles(fileName: String) -> [String] {
        if let pathForResource = NSBundle.mainBundle().pathForResource(fileName, ofType: nil) {
            return contentsOfFile(pathForResource)
        }
        else {
            fatalError("Can't find path")
        }
    }
    
    static func readRecordsFiles(fileName: String) -> [String] {
        let recordsFilePath = pathToDocumentsFolder.stringByAppendingString(fileName)
        return contentsOfFile(recordsFilePath)
    }
    
    static func contentsOfFile(path: String) -> [String] {
        do {
            let wordString = try String(contentsOfFile: path)
            let wordLines = wordString.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet()).filter {$0 != ""}
            return wordLines
        } catch {
            fatalError("Can't read contents of the file")
        }
    }
    
    static func updateRecords(currentScore: String, fileName: String) -> Bool {
        
        var canUpdate = true
        let recordsFilePath = pathToDocumentsFolder.stringByAppendingString(fileName)
        var records = readRecordsFiles(fileName)
        var content = ""
        
        if !records.contains(currentScore) {
            records.append(currentScore)
        }
        records.sortInPlace()
        
        while records.count > 10 {
            records.removeLast()
        }
        
        for score in records {
            if score != "" {
                if content == "" {
                    content = score + "\n"
                } else {
                    content = content + score + "\n"
                }
            }
        }
        
        do {
            try content.writeToFile(recordsFilePath, atomically: true, encoding: NSUTF8StringEncoding)
        } catch {
            canUpdate = false
        }
        return canUpdate
    }
}
