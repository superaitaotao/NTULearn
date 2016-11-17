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
    
    var isInitiated = false
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        if let button = statusIcon.button{
            button.image = #imageLiteral(resourceName: "icon")
            button.alternateImage = #imageLiteral(resourceName: "icon1")
            button.setButtonType(NSButtonType.onOff)
            button.action = #selector(statusIconClicked)
        }
        
        isInitiated = false
        fetcher = NTULearnFetcher(popover: popoverViewController)
        
        //call view to load popover view
        let _ = popoverViewController.view
        
        if !MyUserDefault.sharedInstance.isSavedCourseFoldersPresent() {
            downloadCourseList()
        } else {
            self.isInitiated = true
            let operation = BlockOperation(block: {() -> Void in
                self.fetcher?.logIn(handler: { result in
                    switch result {
                    case FetchResult.logInError:
                        print("log in failed")
                    case FetchResult.success(let data):
                        print("logged in")
                        self.fetcher?.download()
                        self.popoverViewController.infoTextField.stringValue = "downloading your files, please wait ..."
                    default:
                        break
                    }
                })
            })
            fetcher?.logInQueue.addOperation(operation)
        }
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(readyToStartDownload(nc:)), name: NSNotification.Name(rawValue: "CourseFoldersReady"), object: nil)
        nc.addObserver(self, selector: #selector(onDownloadFinished(_:)), name: NSNotification.Name(rawValue: NTULearnFetcher.DownloadFinishedKey), object: nil)
        popoverViewController.settingMenu.item(at: 0)?.action = #selector(showPreferencePage(sender:))
        popoverViewController.downloadButton.action = #selector(startDownload(_:))
    }
    
    func readyToStartDownload(nc: Notification) {
        startDownload(nil)
    }
    
    @IBAction func statusIconClicked(sender: NSButton) {
        popoverViewController.togglePopover(button: sender)
    }
    
    @IBAction func showPreferencePage(sender: AnyObject?) {
        if !isInitiated {
            print ("not initiated yet")
            return
        }
        
        print("showing preference page")
        
        settingWindow = settingViewController.view.window
        if settingWindow == nil{
            settingWindow = NSWindow(contentViewController: settingViewController)
        }
        
        settingWindow?.title = "Setting"
        popoverViewController.closePopover(button: nil)
        settingWindow?.makeKeyAndOrderFront(nil)
        
        settingViewController.refreshButton.action = #selector(refreshCourseList(_:))
    }
    
    func onDownloadFinished(_ : Notification) {
        let num: Int = (fetcher?.noOfDownloadedFiles)!
        popoverViewController.infoTextField.stringValue = "Up to date: \(num) files downloaded"
    }
    
    @IBAction func refreshCourseList(_: NSButton?) {
        let alert = NSAlert()
        alert.messageText = "Warning"
        alert.informativeText = "Are you sure that you want to refresh your course list??"
        alert.icon = #imageLiteral(resourceName: "snorlax_question")
        alert.addButton(withTitle: "No")
        alert.addButton(withTitle: "Yes")
        
        let result = alert.runModal()
        switch result {
        case NSAlertFirstButtonReturn:
            break
        case NSAlertSecondButtonReturn:
            downloadCourseList()
        default:
            break
        }
    }
    
    @IBAction func startDownload(_: NSButton?) {
        fetcher?.download()
        popoverViewController.infoTextField.stringValue = "Downloading your files, please wait"
        downloadCourseList()
    }
    
    func downloadCourseList() {
        let operation = BlockOperation(block: { () -> Void in
            self.fetcher?.getCourseList(handler: { result in
                switch result {
                case FetchResult.logInError:
                    print("log in failed")
                case FetchResult.courseListRetrievalError:
                    print("course list retrieval error")
                case FetchResult.success(let data):
                    print("course list get")
                    self.isInitiated = true
                    OperationQueue.main.addOperation {
                        self.showPreferencePage(sender: nil)
                        self.settingViewController.infoTextField.stringValue = ""
//                        self.settingViewController.courseFolders = []
//                        self.settingViewController.tableView.reloadData()
                        self.settingViewController.courseFolders = MyUserDefault.sharedInstance.getCourseFolders()
                        self.settingViewController.tableView.reloadData()
                    }
                default:
                    print("error")
                    break
                }
            })
        })
        fetcher?.logInQueue.addOperation(operation)
    }
}

