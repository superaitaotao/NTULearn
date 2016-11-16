//
//  AppDelegate.swift
//  NTULearn
//
//  Created by shutao xu on 8/11/16.
//  Copyright © 2016 shutao xu. All rights reserved.
//

import Cocoa
import AppKit
import Kanna

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    let statusIcon = NSStatusBar.system().statusItem(withLength: -2)
    var fetcher : NTULearnFetcher?
    
    let settingViewController = SettingViewController()
    var settingWindow: NSWindow? = nil
    let popoverViewController = PopoverViewController()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        if let button = statusIcon.button{
            button.image = #imageLiteral(resourceName: "icon")
            button.alternateImage = #imageLiteral(resourceName: "icon1")
            button.setButtonType(NSButtonType.onOff)
            button.action = #selector(statusIconClicked)
        }
        
        let operation = BlockOperation(block: { () -> Void in
            self.fetcher?.getCourseList(handler: { result in
                switch result {
                case FetchResult.logInError:
                    print("log in failed")
                case FetchResult.courseListRetrievalError:
                    print("course list retrieval error")
                case FetchResult.success(let data):
                    print("course list get")
                default:
                    break
                }
            })
        })
        
        fetcher = NTULearnFetcher(popover: popoverViewController)
        fetcher?.logInQueue.addOperation(operation)
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(readyToStartDownload(nc:)), name: NSNotification.Name(rawValue: "CourseFoldersReady"), object: nil)
        
        popoverViewController.settingMenu.item(at: 0)?.action = #selector(showPreferencePage(sender:))
    }
    
    func readyToStartDownload(nc: Notification) {
        fetcher?.download()
        popoverViewController.infoTextField.stringValue = "Downloading your files, please wait"
    }
    
    @IBAction func statusIconClicked(sender: NSButton) {
        popoverViewController.togglePopover(button: sender)
    }
    
    @IBAction func showPreferencePage(sender: AnyObject?) {
        print("showing preference page")
       
        settingWindow = settingViewController.view.window
        if settingWindow == nil{
            settingWindow = NSWindow(contentViewController: settingViewController)
        }
        settingWindow?.title = "Setting"
        popoverViewController.closePopover(button: sender!)
        settingWindow?.makeKeyAndOrderFront(nil)
    }
   
    
}

