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
      
        if let _ = MyUserDefault.sharedInstance.getUsername(),
            let _ = MyUserDefault.sharedInstance.getPassword() {
            if !MyUserDefault.sharedInstance.isSavedCourseFoldersPresent() {
                downloadCourseList(refresh: true)
            } else {
                self.popoverViewController.togglePopover(button: statusIcon.button)
                self.isInitiated = true
                let operation = BlockOperation(block: {() -> Void in
                    self.fetcher?.logIn(handler: { result in
                        switch result {
                        case FetchResult.logInError:
                            print("log in failed")
                            self.popoverViewController.infoTextField.stringValue = "log in failed, check your account info & Internet"
                        case FetchResult.success(let _):
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
        downloadTimer?.invalidate()
       
        self.startDownload(nil)
        downloadTimer = Timer.scheduledTimer(withTimeInterval: 3600 * 4, repeats: true, block: {(timer) -> Void in
            print ("start downloading timer...")
            self.startDownload(nil)
        })
    }
    
    func quitApplication() {
        popoverViewController.togglePopover(button: statusIcon.button)
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
        popoverViewController.togglePopover(button: statusIcon.button)
    }
    
    func showLogInWindow() {
        popoverViewController.togglePopover(button: statusIcon.button)
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
        logInViewController.infoTextField.stringValue = ""
        logInWindow?.makeKeyAndOrderFront(nil)
    }
    
    func logInFromLogInWindow(sender: NSButton) {
        setInfoFiledMsg(text: "Logging in, please wait...")
        
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
                    self.setInfoFiledMsg(text: "Log In Failed, please check your username, password & network")
                case FetchResult.success(let data):
                    print("logged in")
                    self.setInfoFiledMsg(text: "Log In Successfully! Initiating NTULearn Downloader...")
                    MyUserDefault.sharedInstance.saveCredential(username: username, password: password)
                    self.downloadCourseList(refresh: false)
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
        
        popoverViewController.togglePopover(button: statusIcon.button)
        settingWindow?.orderFrontRegardless()
        
        settingViewController.refreshButton.action = #selector(refreshCourseList(_:))
    }
    
    func onDownloadFinished(_ : Notification) {
        let num: Int = (fetcher?.noOfDownloadedFiles)!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm dd MMM"
        MyUserDefault.sharedInstance.saveLatestDownloadedFiles(files: popoverViewController.recentFiles)
        popoverViewController.infoTextField.stringValue = "\(num) files downloaded @ \(dateFormatter.string(from: Date()))"
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
            self.settingViewController.infoTextField.stringValue = "Reloading your course list, please wait ..."
            MyUserDefault.sharedInstance.refresh()
            downloadCourseList(refresh: true)
        default:
            break
        }
    }
    
    @IBAction func startDownload(_: NSButton?) {
        fetcher?.download(handler: {(result) -> Void in
            switch result {
            case .logInError(let _):
                self.setInfoFiledMsg(text: "log in failed, check your account info & Internet")
            default:
                break
            }
        })
        
        setInfoFiledMsg(text: "Downloading your files, please wait ...")
        if isFirstTime {
            popoverViewController.togglePopover(button: statusIcon.button)
            isFirstTime = false
        }
 
    }
    
    func downloadCourseList(refresh: Bool) {
        logInWindow?.close()
        
        if !refresh {
            popoverViewController.togglePopover(button: statusIcon.button)
        }
        
        if !refresh && MyUserDefault.sharedInstance.getCourseFolders().count > 0 {
            showPreferencePage(sender: nil)
        } else {
            let operation = BlockOperation(block: { () -> Void in
                self.fetcher?.getCourseList(handler: { result in
                    switch result {
                    case FetchResult.logInError:
                        print("log in failed")
                        if refresh {
                            self.settingViewController.infoTextField.stringValue = "Log in failed, pls check your account info again"
                        } else {
                            self.setInfoFiledMsg(text: "Log in failed, pls check your account info again")
                        }
                    case FetchResult.courseListRetrievalError:
                        print("course list retrieval error")
                    case FetchResult.success(_):
                        print("course list get")
                        self.isInitiated = true
                        OperationQueue.main.addOperation {
                            self.showPreferencePage(sender: nil)
                            self.settingViewController.infoTextField.stringValue = ""
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
    
    func setInfoFiledMsg(text: String) {
        popoverViewController.infoTextField.stringValue = text
    }
}

