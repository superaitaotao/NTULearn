//
//  AppDelegate.swift
//  NTULearn
//
//  Created by shutao xu on 8/11/16.
//  Copyright © 2016 shutao xu. All rights reserved.
//

import Cocoa
import AppKit

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
        fetcher.logIn{ (result: FetchResult)->Void in
            switch result {
            case .success(let data):
                let dataString = String(data: data, encoding: String.Encoding.utf8)
//                let kanna = Kanna.HTML(html: dataString, encoding: String.Encoding.utf8)
                
            case .error(let error) :
                print("log in failed")
            }
        }
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

