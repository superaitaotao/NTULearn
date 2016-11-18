//
//  SettingStackView.swift
//  NewNTULearn
//
//  Created by shutao xu on 9/11/16.
//  Copyright © 2016 shutao xu. All rights reserved.
//

import Cocoa

class SettingStackRow: NSStackView{
    
    var checkBox: NSButton = NSButton(checkboxWithTitle: "", target: nil, action: nil)
    var textView: NSTextField = NSTextField()
    var checked: BoolWrapper = BoolWrapper(false)
    
    init(checked: BoolWrapper, text: String, fontsize: Int, leftPadding: Int, rowHeight: Int, rowWidth: Int) {
        
        super.init(frame: NSRect(x: 0, y: 0, width: rowWidth, height: rowHeight))
        
        checkBox.title = ""
        checkBox.state = checked.value ? 1 : 0
        
        
        self.checked = checked
        
        textView.isEditable = false
        textView.font = NSFont.systemFont(ofSize: CGFloat(fontsize))
        textView.stringValue = text
        textView.allowsEditingTextAttributes = true
        
        textView.backgroundColor = NSColor(calibratedRed: 0, green: 0, blue: 0, alpha: 0)
        textView.isBordered = false
        textView.drawsBackground = true
  
        setViews([checkBox, textView], in: .leading)
        self.orientation = .horizontal
        checkBox.leftAnchor.constraint(equalTo: self.leftAnchor, constant: CGFloat(leftPadding)).isActive = true
        textView.leftAnchor.constraint(equalTo: checkBox.rightAnchor, constant: 10).isActive = true
    
        checkBox.target = self
        checkBox.action = #selector(onCheckboxChanged(sender:))
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBAction func onCheckboxChanged(sender: NSButton) {
        checked.value = sender.state == 1 ? true : false
    }
}

class BoolWrapper : NSObject{
    var value : Bool
    init(_ bool: Bool) {
        value = bool
    }
}
