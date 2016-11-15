//
//  FileInfo.swift
//  NewNTULearn
//
//  Created by shutao xu on 8/11/16.
//  Copyright © 2016 shutao xu. All rights reserved.
//

import Foundation

class FileInfo: NSObject{
    let fileName : String
    let courseName: String
    let syncDate: Date
    let fileUrl: URL?
    
    init(fileName: String, courseName: String, syncDate: Date, fileUrl: URL?) {
        self.fileName = fileName
        self.courseName = courseName
        self.syncDate = syncDate
        self.fileUrl = fileUrl
    }
}
