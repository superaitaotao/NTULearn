//
//  EventMonitor.swift
//  NewNTULearn
//
//  Created by shutao xu on 8/11/16.
//  Copyright © 2016 shutao xu. All rights reserved.
//

import Cocoa

class EventMonitor {
    private var monitor: Any?
    private let mask: NSEventMask
    private let handler: (NSEvent?) -> Void
    
    public init(mask: NSEventMask, handler: @escaping (NSEvent?) -> Void) {
        self.mask = mask
        self.handler = handler
    }
    
    deinit {
        stop()
    }
    
    public func start() {
        monitor = NSEvent.addGlobalMonitorForEvents(matching: mask, handler: handler)
    }
    
    public func stop() {
        if monitor != nil {
            NSEvent.removeMonitor(monitor!)
            monitor = nil
        }
    }
}
