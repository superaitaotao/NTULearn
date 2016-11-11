//
//  CourseInfo.swift
//  NewNTULearn
//
//  Created by shutao xu on 9/11/16.
//  Copyright © 2016 shutao xu. All rights reserved.
//

import Foundation

public class CourseInfo: NSObject{
    var name: String
    var folders: [String]
    var foldersChecked: [Bool]
    var isChecked: Bool
    
    convenience init(name: String, folders: [String]) {
        var foldersChecked: [Bool] = []
        for _ in 0 ..< folders.count  {
            foldersChecked.append(false)
        }
        self.init(name:name, folders: folders, isChecked: false, foldersChecked: foldersChecked)
    }
    
    init(name: String, folders: [String], isChecked: Bool, foldersChecked: [Bool]) {
        self.name = name
        self.folders = folders
        self.foldersChecked = foldersChecked
        self.isChecked = isChecked
    }
    
    override public var description: String {
        var s: String = ""
        s += "\(self.name)  : \(isChecked) \n"
        for i in 0 ..< folders.count {
            s += "\(folders[i]) : \(foldersChecked[i]) \n"
        }
        s += "\n"
        return s
    }
}
