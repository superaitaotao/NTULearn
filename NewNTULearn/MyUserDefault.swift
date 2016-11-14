//
//  File.swift
//  NewNTULearn
//
//  Created by shutao xu on 12/11/16.
//  Copyright © 2016 shutao xu. All rights reserved.
//

import Cocoa

class MyUserDefault {
    static let sharedInstance = MyUserDefault()
    private let userDefaults = UserDefaults.standard
    private init() {}
    
    func saveCourseFolders(courseFolders : [CourseInfo]) {
        var allCourseInfo: [[String: Any]] = []
        var oneCourseInfo: [String: Any]
        var oneCourseFolders: [[Any]]
        
        for course in courseFolders {
            oneCourseInfo = [:]
            oneCourseInfo["courseName"] = course.name
            oneCourseInfo["isChecked"] = course.isChecked.value
            
            oneCourseFolders = []
            
            for i in 0 ..< course.folders.count {
                oneCourseFolders.append([course.folders[i],course.foldersChecked[i].value, course.foldersUrl[i]])
            }
            
            oneCourseInfo["folders"] = oneCourseFolders
            allCourseInfo.append(oneCourseInfo)
        }
        
        userDefaults.register(defaults:["courseFoldersSetting" : allCourseInfo])
    }
    
    func getCourseFolders() -> [CourseInfo]{
        var courseFolders: [CourseInfo] = []
        
        let courseArray = userDefaults.array(forKey: "courseFoldersSetting") as! [[String: Any]]
        var oneCourseInfo: CourseInfo
        var foldersChecked: [BoolWrapper]
        var folders: [String]
        var foldersUrl: [String]
        
        for course in courseArray {
            foldersChecked = []
            folders = []
            foldersUrl = []
            for folder in course["folders"] as! [[Any]]{
                folders.append(folder[0] as! String)
                foldersChecked.append(BoolWrapper(folder[1] as! Bool))
                foldersUrl.append(folder[2] as! String)
            }
            oneCourseInfo = CourseInfo(name: course["courseName"] as! String, folders: folders, isChecked: BoolWrapper(course["isChecked"] as! Bool), foldersChecked: foldersChecked, foldersUrl: foldersUrl)
            courseFolders.append(oneCourseInfo)
        }
        
        return courseFolders
    }
    
}
