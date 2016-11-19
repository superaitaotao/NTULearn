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
    let logInViewController = LogInViewController()
    var logInWindow: NSWindow? = nil
    let aboutViewController = AboutViewController()
    var aboutWindow: NSWindow? = nil
    
    var isInitiated = false
    var isFirstTime = true
    
    var downloadTimer: Timer?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        if let button = statusIcon.button{
            button.image = #imageLiteral(resourceName: "icon")
            button.alternateImage = #imageLiteral(resourceName: "icon1")
            button.setButtonType(NSButtonType.onOff)
            button.action = #selector(statusIconClicked(sender:))
        }
        
        isInitiated = false
        fetcher = NTULearnFetcher(popover: popoverViewController)
        
        //call view to load popover view
        let _ = popoverViewController.view
      
        if let username = MyUserDefault.sharedInstance.getUsername(),
            let password = MyUserDefault.sharedInstance.getPassword() {
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
                            self.scheduleTimer()
                            self.popoverViewController.infoTextField.stringValue = "downloading your files, please wait ..."
                        default:
                            break
                        }
                    })
                })
                fetcher?.logInQueue.addOperation(operation)
            }
        } else {
            showLogInWindow()
        }
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(readyToStartDownload(nc:)), name: NSNotification.Name(rawValue: "CourseFoldersReady"), object: nil)
        nc.addObserver(self, selector: #selector(onDownloadFinished(_:)), name: NSNotification.Name(rawValue: NTULearnFetcher.DownloadFinishedKey), object: nil)
        
        popoverViewController.settingMenu.item(at: 0)?.action = #selector(showPreferencePage(sender:))
        popoverViewController.settingMenu.item(at: 1)?.action = #selector(showLogInWindow)
        popoverViewController.settingMenu.item(at: 2)?.action = #selector(showAboutWindow)
        popoverViewController.settingMenu.item(at: 3)?.action = #selector(quitApplication)
        popoverViewController.downloadButton.action = #selector(scheduleTimer)
    }
    
    func scheduleTimer() {
        if downloadTimer != nil {
            downloadTimer?.invalidate()
        }
       
        self.startDownload(nil)
        downloadTimer = Timer.scheduledTimer(withTimeInterval: 3600 * 12, repeats: true, block: {(timer) -> Void in
            print ("start downloading timer...")
            self.startDownload(nil)
        })
    }
    
    func quitApplication() {
        popoverViewController.closePopover(button: statusIcon.button)
        let alert = NSAlert()
        alert.messageText = "Warning"
        alert.informativeText = "Wanna quit NTULearn Downloader?"
        alert.icon = #imageLiteral(resourceName: "snorlax_question")
        alert.addButton(withTitle: "No")
        alert.addButton(withTitle: "Yes")
        let result = alert.runModal()
        switch result {
        case NSAlertFirstButtonReturn:
            break
        case NSAlertSecondButtonReturn:
            NSApplication.shared().terminate(self)
        default:
            break
        }
    }
    
    func showAboutWindow() {
        aboutWindow = aboutViewController.view.window
        if aboutWindow == nil {
            aboutWindow = NSWindow(contentViewController: aboutViewController)
            aboutWindow?.title = "About"
            aboutWindow?.minSize = (aboutWindow?.frame.size)!
            aboutWindow?.maxSize = (aboutWindow?.frame.size)!
        }
        aboutWindow?.makeKeyAndOrderFront(nil)
        popoverViewController.closePopover(button: statusIcon.button)
    }
    
    func showLogInWindow() {
        popoverViewController.closePopover(button: statusIcon.button)
        logInWindow = logInViewController.view.window
        if logInWindow == nil {
            logInWindow = NSWindow(contentViewController: logInViewController)
            logInWindow?.minSize = logInWindow!.frame.size
            logInWindow?.maxSize = logInWindow!.frame.size
            logInWindow?.title = "Log In"
            logInViewController.logInButton.action = #selector(logInFromLogInWindow(sender:))
            if let username = MyUserDefault.sharedInstance.getUsername(),
                let password = MyUserDefault.sharedInstance.getPassword() {
                    logInViewController.userNameField.stringValue = username
                    logInViewController.passwordField.stringValue = password
            }
        }
        logInViewController.infoTextField.stringValue = "NTU Learn"
        logInWindow?.makeKeyAndOrderFront(nil)
    }
    
    func logInFromLogInWindow(sender: NSButton) {
        logInViewController.infoTextField.stringValue = "Logging in, please wait..."
        
        let username = logInViewController.userNameField.stringValue.trimmingCharacters(in: CharacterSet(charactersIn: " "))
        let password = logInViewController.passwordField.stringValue.trimmingCharacters(in: CharacterSet(charactersIn: " "))
        
        if username == "" || password == "" {
            self.logInViewController.infoTextField.stringValue = "Invalid username or password used..."
        } else {
            fetcher?.username = username
            fetcher?.password = password
            self.fetcher?.logIn(handler: { result in
                switch result {
                case FetchResult.logInError:
                    print("log in failed")
                    self.logInViewController.infoTextField.stringValue = "Log In Failed, please check your username, password & network"
                case FetchResult.success(let data):
                    print("logged in")
                    self.logInViewController.infoTextField.stringValue = "Log In Successfully! Initiating NTULearn Downloader..."
                    MyUserDefault.sharedInstance.saveCredential(username: username, password: password)
                    self.downloadCourseList()
                default:
                    break
                }
            })
        }
    }
    
    func readyToStartDownload(nc: Notification) {
        scheduleTimer()
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
            settingWindow?.minSize = NSSize(width: 480, height: 340)
            settingWindow?.maxSize = NSSize(width: 480, height: 340)
            settingWindow?.title = "NTULearn Setting"
        }
        
        popoverViewController.closePopover(button: nil)
        settingWindow?.orderFrontRegardless()
        
        settingViewController.refreshButton.action = #selector(refreshCourseList(_:))
    }
    
    func onDownloadFinished(_ : Notification) {
        let num: Int = (fetcher?.noOfDownloadedFiles)!
        MyUserDefault.sharedInstance.saveLatestDownloadedFiles(files: popoverViewController.recentFiles)
        popoverViewController.infoTextField.stringValue = "Up to date: \(num) files downloaded"
        MyUserDefault.sharedInstance.sync()
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
            popoverViewController.infoTextField.stringValue = "Reloading your course list, please wait ..."
            downloadCourseList()
        default:
            break
        }
    }
    
    @IBAction func startDownload(_: NSButton?) {
        fetcher?.download()
        popoverViewController.infoTextField.stringValue = "Downloading your files, please wait ..."
        if isFirstTime {
            popoverViewController.showPopover(button: statusIcon.button)
            isFirstTime = false
        }
 
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
                        self.settingViewController.courseFolders = MyUserDefault.sharedInstance.getCourseFolders()
                        self.settingViewController.tableView.reloadData()
                        self.logInWindow?.close()
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

