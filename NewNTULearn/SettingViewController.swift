//  SettingViewController.swift
//  NewNTULearn
//
//  Created by shutao xu on 9/11/16.
//  Copyright © 2016 shutao xu. All rights reserved.
//

import Cocoa

class SettingViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate{
    
    @IBOutlet private var tableView: NSTableView?
    @IBOutlet private var doneButton: NSButton?
    
    private var courseFolders: [CourseInfo] = []
    let smallRowHeight: Int = 30
    let bigRowheight: Int = 50
    
    func setUpSettingTable() {
        let course1 = CourseInfo(name: "RE6001", folders: ["content1", "assignment1"])
        let course2 = CourseInfo(name: "RE6002", folders: ["content2", "assignment2"])
        let course3 = CourseInfo(name: "RE6003", folders: ["content3", "assignment3", "fsdafdsfsd"])
        let courses : [CourseInfo] = [course1, course2, course3]
        
        var allCourseInfo: [[String: Any]] = []
        var oneCourseInfo: [String: Any]
        var oneCourseFolders: [[Any]]
        for course in courses {
            oneCourseInfo = [:]
            oneCourseInfo["courseName"] = course.name
            oneCourseInfo["isChecked"] = course.isChecked.value
            
            oneCourseFolders = []
            for i in 0 ..< course.folders.count {
                oneCourseFolders.append([course.folders[i],course.foldersChecked[i].value])
            }
            oneCourseInfo["folders"] = oneCourseFolders
            allCourseInfo.append(oneCourseInfo)
        }
        
        UserDefaults.standard.register(defaults:["courseFoldersSetting" : allCourseInfo])
    }
    
    func getCourseFolders() -> [CourseInfo] {
        return courseFolders
    }
    
    func setCourseFolders() {
        self.courseFolders = []
        
        let courseArray = UserDefaults.standard.array(forKey: "courseFoldersSetting") as! [[String: Any]]
        var oneCourseInfo: CourseInfo
        var foldersChecked: [BoolWrapper]
        var folders: [String]
        
        for course in courseArray {
            foldersChecked = []
            folders = []
            for folder in course["folders"] as! [[Any]]{
                folders.append(folder[0] as! String)
                foldersChecked.append(BoolWrapper(folder[1] as! Bool))
            }
            oneCourseInfo = CourseInfo(name: course["courseName"] as! String, folders: folders, isChecked: BoolWrapper(course["isChecked"] as! Bool), foldersChecked: foldersChecked)
            courseFolders.append(oneCourseInfo)
        }
    }
    
    func saveCourseFolders() {
        var allCourseInfo: [[String: Any]] = []
        var oneCourseInfo: [String: Any]
        var oneCourseFolders: [[Any]]
        for course in courseFolders {
            oneCourseInfo = [:]
            oneCourseInfo["courseName"] = course.name
            oneCourseInfo["isChecked"] = course.isChecked.value
            
            oneCourseFolders = []
            for i in 0 ..< course.folders.count {
                oneCourseFolders.append([course.folders[i],course.foldersChecked[i].value])
            }
            oneCourseInfo["folders"] = oneCourseFolders
            allCourseInfo.append(oneCourseInfo)
        }
        
        UserDefaults.standard.register(defaults:["courseFoldersSetting" : allCourseInfo])
    }
    
    override func viewDidLoad() {
        if UserDefaults.standard.array(forKey: "courseFoldersSetting") == nil {
            print("default nil")
            setUpSettingTable()
        }
        setCourseFolders()
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return courseFolders.count
    }
    
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let view: NSStackView = tableView.make(withIdentifier: "myStack", owner: self) as! NSStackView
        let courseInfo = courseFolders[row]
        
        var stackView: NSStackView
        
        stackView = SettingStackRow(checked: courseInfo.isChecked, text: courseInfo.name, fontsize: 20, leftPadding: 20, rowHeight: bigRowheight)
        view.addArrangedSubview(stackView)
        
        for i in 0 ..< courseInfo.folders.count{
            stackView = SettingStackRow(checked: courseInfo.foldersChecked[i], text: courseInfo.folders[i], fontsize: 15, leftPadding: 40, rowHeight: smallRowHeight)
            view.addArrangedSubview(stackView)
        }
    
        return view
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        let courseInfo = courseFolders[row]
        return CGFloat(bigRowheight + smallRowHeight * courseInfo.folders.count)
    }
    
    @IBAction func onDoneClicked(sender: NSButton) {
        saveCourseFolders()
        view.window?.close()
    }
}
