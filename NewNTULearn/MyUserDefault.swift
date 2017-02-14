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
    
    let courseFoldersKey = "courseFoldersSetting"
    let latestDownloadedKey = "latestDownloadedFiles"
    let donwloadedFileUrlsKey = "downloadedFileUrls"
    
    func saveCourseFolders(courseFolders : [CourseInfo]) {
        print("course folders saved")
        var allCourseInfo: [[String: Any]] = []
        var oneCourseInfo: [String: Any]
        var oneCourseFolders: [[Any]]
        
        for course in courseFolders {
            oneCourseInfo = [:]
            oneCourseInfo["courseName"] = proccessCourseName(name: course.name)
            oneCourseInfo["isChecked"] = course.isChecked.value
            
            oneCourseFolders = []
            
            for i in 0 ..< course.folders.count {
                oneCourseFolders.append([course.folders[i],course.foldersChecked[i].value, course.foldersUrl[i]])
            }
            
            oneCourseInfo["folders"] = oneCourseFolders
            allCourseInfo.append(oneCourseInfo)
        }
       
        userDefaults.set(allCourseInfo, forKey: courseFoldersKey)
    }
    
    func getCourseFolders() -> [CourseInfo]{
        var courseFolders: [CourseInfo] = []
        
        let courseArray = userDefaults.array(forKey: courseFoldersKey) as! [[String: Any]]?
        var oneCourseInfo: CourseInfo
        var foldersChecked: [BoolWrapper]
        var folders: [String]
        var foldersUrl: [String]
        
        if let courseArray = courseArray {
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
        }
        
        return courseFolders
    }
   
    //supposed to modify the course name to be shorter...
    func proccessCourseName(name: String) -> String {
        return name
    }
    
    func isSavedCourseFoldersPresent() -> Bool{
        return userDefaults.array(forKey: courseFoldersKey) != nil
    }
    
    func getLatestDownloadedFiles() -> [FileInfo] {
        let filesDefault = userDefaults.array(forKey: latestDownloadedKey) as! [[AnyObject]]?
        var files: [FileInfo] = []
        var oneFile: FileInfo
        if let filesDefault = filesDefault {
            for file in filesDefault {
                oneFile = FileInfo(fileName: file[0] as! String, courseName: file[1] as! String, syncDate: file[2] as! Date , fileUrl: URL(fileURLWithPath:file[3] as! String))
                files.append(oneFile)
            }
        }
        
        return files
    }
    
    func saveLatestDownloadedFiles(files: [FileInfo]) {
        print("save latest downloaded files")
        var filesDefault: [[AnyObject]] = []
        
        for file in files {
            let fileUrl = file.fileUrl?.path
            filesDefault.append([file.fileName as AnyObject, file.courseName as AnyObject, file.syncDate as AnyObject, fileUrl as AnyObject])
        }
       
        userDefaults.set(filesDefault, forKey: latestDownloadedKey)
    }
    
    func addLatestDownloadedFile(file: FileInfo) {
        var files = getLatestDownloadedFiles()
        files.append(file)
        if files.count > 10 {
            files.remove(at: 0)
        }
        saveLatestDownloadedFiles(files: files)
    }
    
    func getUsername() -> String? {
        return userDefaults.string(forKey: "username")
    }
    
    func getPassword() -> String? {
        return userDefaults.string(forKey: "password")
    }
    
    func saveCredential(username: String, password: String) {
        print("saved credentials")
        userDefaults.set(username, forKey: "username")
        userDefaults.set(password, forKey: "password")
    }
    
    func saveDownloadedFileUrls(fileUrls: Set<String>) {
        var urls: [String] = []
        for url in fileUrls {
            urls.append(url)
        }
        userDefaults.set(urls, forKey: donwloadedFileUrlsKey)
    }
    
    func getDownloadedFileUrls() -> Set<String>{
        let urls = userDefaults.array(forKey: donwloadedFileUrlsKey)
        var set: Set<String> = Set()
        if urls != nil {
            for url in urls! {
                set.insert(url as! String)
            }
        }
        return set
    }
    
    func sync() {
        userDefaults.synchronize()
    }
    
    func refresh() {
        userDefaults.removeObject(forKey: donwloadedFileUrlsKey)
        //bad approach...
        NTULearnFetcher.downloadedFileUrls = []
    }
}
