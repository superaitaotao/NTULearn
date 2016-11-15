//
//  PopoverViewController.swift
//  NTULearn
//
//  Created by shutao xu on 8/11/16.
//  Copyright © 2016 shutao xu. All rights reserved.
//

import Cocoa

class PopoverViewController: NSViewController {
    
    private dynamic var recentFiles : [FileInfo] = []
    
    @IBOutlet var settingButton: NSButton!
    @IBOutlet var goToFolderButton: NSButton!
    
    let settingMenu: NSMenu = NSMenu()
    var popover: NSPopover = NSPopover()
    
    var eventMonitor : EventMonitor?
   
    init() {
        popover.animates = false
        
        settingMenu.addItem(NSMenuItem(title: "Preference", action: nil, keyEquivalent: ""))
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
        // Do view setup here.
        for _ in 0..<10 {
            recentFiles.append(FileInfo(fileName: "Week 7 LMRP Excel Example.xlsx", courseName: "RE6007", syncDate: Date(), fileUrl: nil))
        }
        
        if eventMonitor == nil {
            eventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown], handler: { (event) -> Void in
                if (self.popover.isShown) {
                    self.popover.close()
                }
            })
        }
        
        settingButton.action = #selector(showSettingMenu(sender:))
        goToFolderButton.action = #selector(openNTULearnFolder(sender:))
    }
    
    override var nibName: String? {
        return "PopoverViewController"
    }
    
    @IBAction func showSettingMenu(sender: NSButton) {
        settingMenu.popUp(positioning: settingMenu.item(at:0) , at: NSPoint(x: 0, y: settingButton.frame.size.height + 7), in: settingButton)
    }
    
    func showPopover(button: AnyObject) {
        if popover.contentViewController == nil {
            popover.contentViewController = self
        }
        
        popover.show(relativeTo: button.bounds, of: button as! NSButton, preferredEdge: NSRectEdge.minY)
        eventMonitor?.start()
        print("show popover")
    }
    
    func closePopover(button: AnyObject) {
        popover.performClose(button)
        eventMonitor?.stop()
        print("close popover")
    }

    func togglePopover(button: AnyObject) {
        if (popover.isShown) {
            closePopover(button: button)
        } else {
            showPopover(button: button)
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
