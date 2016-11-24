//
//  PopoverViewController.swift
//  NTULearn
//
//  Created by shutao xu on 8/11/16.
//  Copyright © 2016 shutao xu. All rights reserved.
//

import Cocoa

class PopoverViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    
    var recentFiles : [FileInfo] = MyUserDefault.sharedInstance.getLatestDownloadedFiles()
    
    @IBOutlet var tableView: NSTableView!
    @IBOutlet var settingButton: NSButton!
    @IBOutlet var goToFolderButton: NSButton!
    @IBOutlet var infoTextField: NSTextField!
    @IBOutlet var downloadButton: NSButton!
    
    let settingMenu: NSMenu = NSMenu()
    var popover: NSPopover = NSPopover()
    
    var eventMonitor : EventMonitor?
    var numberOfFileDownloaded = 0
   
    init() {
        popover.animates = false
        settingMenu.addItem(NSMenuItem(title: "Preference", action: nil, keyEquivalent: ""))
        settingMenu.addItem(NSMenuItem(title: "Account", action: nil, keyEquivalent: ""))
        settingMenu.addItem(NSMenuItem(title: "About", action: nil, keyEquivalent: ""))
        settingMenu.addItem(NSMenuItem(title: "Quit", action: nil, keyEquivalent: ""))
        
        super.init(nibName: nil, bundle: nil)!
        
        print("PopoverView initiated")
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if eventMonitor == nil {
            eventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown], handler: { (event) -> Void in
                if (self.popover.isShown) {
                    self.closePopover(button: nil)
                }
            })
        }
        
        settingButton.action = #selector(showSettingMenu(sender:))
        goToFolderButton.action = #selector(openNTULearnFolder(sender:))
        infoTextField.stringValue = "initiating... please wait"
    }
    
    override var nibName: String? {
        return "PopoverViewController"
    }
    
    @IBAction func showSettingMenu(sender: NSButton) {
        settingMenu.popUp(positioning: settingMenu.item(at:0) , at: NSPoint(x: 0, y: settingButton.frame.size.height + 7), in: settingButton)
    }
    
    private func showPopover(button: AnyObject?) {
        popover.show(relativeTo: (button?.bounds)!, of: button as! NSButton, preferredEdge: NSRectEdge.minY)
        eventMonitor?.start()
    }
    
    private func closePopover(button: AnyObject?) {
        popover.performClose(button)
        eventMonitor?.stop()
    }

    func togglePopover(button: AnyObject?) {
        if popover.contentViewController == nil {
            popover.contentViewController = self
        }
        
        if (popover.isShown) {
            closePopover(button: button)
        } else {
            showPopover(button: button)
        }
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell  = tableView.make(withIdentifier: "cell", owner: self) as! NSTableCellView
        var textFields = cell.subviews as! [NSTextField]
        let fileInfo = recentFiles[row]
        
        textFields[0].stringValue = fileInfo.courseName
        textFields[1].stringValue = fileInfo.fileName
        textFields[2].objectValue = fileInfo.syncDate
        
        return cell
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return recentFiles.count
    }
    
    @IBAction func onTableClicked(sender: AnyObject) {
        let tableView = sender as! NSTableView
           if tableView.selectedRow != -1 {
            let url = recentFiles[tableView.selectedRow].fileUrl
            if let url = url {
                if FileManager.default.fileExists(atPath: url.path) {
                    var containingDir = URL(fileURLWithPath: url.path)
                    containingDir.deleteLastPathComponent()
                    NSWorkspace.shared().open(containingDir)
                } else {
                    print("file not exists : \(url)")
                }
            }
        }
    }
    
    @IBAction func openNTULearnFolder(sender: NSButton) {
        let path = URL(fileURLWithPath: "/Users/shutaoxu/NTULearn")
        if !(FileManager.default.fileExists(atPath: path.absoluteString)) {
            do {
                try FileManager.default.createDirectory(at: path, withIntermediateDirectories: true, attributes: nil)
            } catch is Error {
                print("error: create directory at \(path.absoluteString)")
            }
        }
        NSWorkspace.shared().open(path)
        closePopover(button: sender)
    }

    
}
