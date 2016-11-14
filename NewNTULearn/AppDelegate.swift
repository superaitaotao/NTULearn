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
    
    var statusIcon = NSStatusBar.system().statusItem(withLength: -2)
    var popover = NSPopover()
    var eventMonitor : EventMonitor?
    var fetcher : NTULearnFetcher = NTULearnFetcher()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        if let button = statusIcon.button{
            button.image = #imageLiteral(resourceName: "icon")
            button.alternateImage = #imageLiteral(resourceName: "icon1")
            button.setButtonType(NSButtonType.onOff)
            button.action = #selector(statusIconClicked)
        }
        popover.contentViewController = PopoverViewController(popover: popover)
//        popover.behavior = NSPopoverBehavior.transient
        popover.animates = false
        
        if eventMonitor == nil {
            eventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown], handler: {
                event in
                print ("down")
                if self.popover.isShown {
                    self.closePopover(button: event!)
                }
            })
        }
        
        var operation = BlockOperation(block: { () -> Void in
            self.fetcher.getCourseList(handler: { result in
                switch result {
                case FetchResult.logInError:
                    print("log in failed")
                case FetchResult.courseListRetrievalError:
                    print("course list retrieval error")
                case FetchResult.success(let data):
                    print("course list get")
//                    self.fetcher.downloadRec(url:"/webapps/blackboard/content/listContent.jsp?course_id=_121297_1&content_id=_914554_1", path: "",courseName: "")
                    self.fetcher.downloadRec(url:"/webapps/blackboard/content/listContent.jsp?course_id=_121297_1&content_id=_872153_1", path: "",courseName: "")
                default:
                    break
                }
            })
        })
        
        fetcher.logInQueue.addOperation(operation)
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    @IBAction func statusIconClicked(sender: NSButton) {
        togglePopover(button: sender)
    }
    
    func showPopover(button: AnyObject) {
        popover.show(relativeTo: button.bounds, of: button as! NSButton, preferredEdge: NSRectEdge.minY)
        eventMonitor?.start()
    }
    

    func closePopover(button: AnyObject) {
        popover.performClose(button)
        eventMonitor?.stop()
    }
    
    func togglePopover(button: AnyObject) {
        let button = button as! NSButton
        if popover.isShown {
            closePopover(button: button)
        } else {
            showPopover(button: button)
            button.state = 0
        }
    }

   
    
}

