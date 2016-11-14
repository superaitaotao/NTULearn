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
    var foldersChecked: [BoolWrapper]
    var foldersUrl: [String]
    var isChecked: BoolWrapper
    
    convenience init(name: String, folders: [String], foldersUrl: [String]) {
        var foldersChecked: [BoolWrapper] = []
        for _ in 0 ..< folders.count  {
            foldersChecked.append(BoolWrapper(false))
        }
        self.init(name:name, folders: folders, isChecked: BoolWrapper(false), foldersChecked: foldersChecked, foldersUrl: foldersUrl)
    }
    
    init(name: String, folders: [String], isChecked: BoolWrapper, foldersChecked: [BoolWrapper], foldersUrl: [String]) {
        self.name = name
        self.folders = folders
        self.foldersChecked = foldersChecked
        self.isChecked = isChecked
        self.foldersUrl = foldersUrl
    }
    
    override public var description: String {
        var s: String = ""
        s += "\(self.name)  : \(isChecked.value) \n"
        for i in 0 ..< folders.count {
            s += "\(folders[i]) : \(foldersChecked[i].value) \n"
        }
        s += "\n"
        return s
    }
}
