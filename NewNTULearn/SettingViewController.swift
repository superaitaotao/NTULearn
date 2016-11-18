//  SettingViewController.swift
//  NewNTULearn
//
//  Created by shutao xu on 9/11/16.
//  Copyright © 2016 shutao xu. All rights reserved.
//

import Cocoa

class SettingViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate{
    
    @IBOutlet var tableView: NSTableView!
    @IBOutlet var doneButton: NSButton?
    @IBOutlet var refreshButton: NSButton!
    @IBOutlet var infoTextField: NSTextField!
    
    var courseFolders: [CourseInfo] = []
    let smallRowHeight: Int = 30
    let bigRowheight: Int = 60
    let userDefault = MyUserDefault.sharedInstance
    
    override func viewDidLoad() {
        if UserDefaults.standard.array(forKey: "courseFoldersSetting") == nil {
            print("default nil")
//            setUpSettingTable()
        }
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return courseFolders.count
    }
    
    override var nibName: String? {
        return "SettingViewController"
    }
    
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let view: NSTableCellView = tableView.make(withIdentifier: "nil", owner: self) as! NSTableCellView
        let courseInfo = courseFolders[row]
        
        for sub in view.subviews {
            sub.removeFromSuperview()
        }
        
        var preView: NSStackView
        var nextView: NSStackView
        let width: Int = Int(view.frame.size.width)
        
        preView = SettingStackRow(checked: courseInfo.isChecked, text: courseInfo.name, fontsize: 16, leftPadding: 20, rowHeight: bigRowheight, rowWidth: width).get()
        view.addSubview(preView)
        preView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        preView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        
        for i in 0 ..< courseInfo.folders.count{
            nextView = SettingStackRow(checked: courseInfo.foldersChecked[i], text: courseInfo.folders[i], fontsize: 13, leftPadding: 40, rowHeight: smallRowHeight, rowWidth: width).get()
            view.addSubview(nextView)
            nextView.topAnchor.constraint(equalTo: preView.bottomAnchor).isActive = true
            nextView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            preView = nextView
        }
    
        return view
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        let courseInfo = courseFolders[row]
        return CGFloat(bigRowheight + smallRowHeight * courseInfo.folders.count)
    }
    
    @IBAction func onDoneClicked(sender: NSButton) {
        userDefault.saveCourseFolders(courseFolders: courseFolders)
        view.window?.close()
        let nc = NotificationCenter.default
        nc.post(name: NSNotification.Name(rawValue: "CourseFoldersReady"), object: nil)
    }
}
