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
    private let settingMenu: NSMenu = NSMenu()
    private let firstMenuItem: NSMenuItem = NSMenuItem(title: "Preference", action: nil, keyEquivalent: "")
    private let settingViewController = SettingViewController()
    private var preferenceWindow: NSWindow?
    private weak var popover: NSPopover?
    
    init(popover: NSPopover) {
        super.init(nibName: nil, bundle: nil)!
        self.popover = popover
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        for _ in 0..<10 {
            recentFiles.append(FileInfo(fileName: "Week 7 LMRP Excel Example.xlsx", courseName: "RE6007", syncDate: Date()))
        }
        
        settingMenu.addItem(firstMenuItem)
        settingMenu.addItem(NSMenuItem(title: "About", action: nil, keyEquivalent: ""))
        settingMenu.addItem(NSMenuItem(title: "Quit", action: nil, keyEquivalent: ""))
        
        firstMenuItem.action = #selector(showPreferencePage(sender:))
//        view.window?.collectionBehavior = NSWindowCollectionBehavior.fullScreenAuxiliary
    }
    
    override var nibName: String? {
        return "PopoverViewController"
    }
    
    @IBAction func showSettingMenu(sender: NSButton) {
        settingMenu.popUp(positioning: firstMenuItem, at: NSPoint(x: 0, y: settingButton.frame.size.height + 7), in: settingButton)
    }
    
    @IBAction func showPreferencePage(sender: AnyObject?) {
        print("showing preference page")
        if preferenceWindow == nil {
            preferenceWindow = NSWindow(contentViewController: settingViewController)
            preferenceWindow?.title = "Setting"
        }
        popover?.close()
        preferenceWindow?.makeKeyAndOrderFront(nil)
    }
}
