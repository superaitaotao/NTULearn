//
//  SettingStackView.swift
//  NewNTULearn
//
//  Created by shutao xu on 9/11/16.
//  Copyright © 2016 shutao xu. All rights reserved.
//

import Cocoa

class SettingStackRow: NSStackView{

    let checkBox: NSButton = NSButton(checkboxWithTitle: "", target: nil, action: nil)
    let textView: NSTextField = NSTextField()
    var checked: BoolWrapper = BoolWrapper(false)
    
    init(checked: BoolWrapper, text: String, fontsize: Int, leftPadding: Int, rowHeight: Int) {
        super.init(frame: CGRect(x: 0, y: 0, width: 10, height: rowHeight))
        
        self.checked = checked
        checkBox.title = ""
        checkBox.target = self
        checkBox.action = #selector(onCheckboxChanged(sender:))
        checkBox.state = checked.value ? 1 : 0
        
        textView.isEditable = false
        textView.font = NSFont.systemFont(ofSize: CGFloat(fontsize))
        textView.stringValue = text
        textView.allowsEditingTextAttributes = true
        
        textView.backgroundColor = NSColor(calibratedRed: 0, green: 0, blue: 0, alpha: 0)
        textView.isBordered = false
        textView.drawsBackground = true
    
        setViews([checkBox, textView], in: NSStackViewGravity.leading)
        
        checkBox.leftAnchor.constraint(equalTo: self.leftAnchor, constant: CGFloat(leftPadding)).isActive = true
        textView.leftAnchor.constraint(equalTo: checkBox.rightAnchor, constant: 10).isActive = true
        self.heightAnchor.constraint(equalToConstant: CGFloat(rowHeight)).isActive = true
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    @IBAction func onCheckboxChanged(sender: NSButton) {
        self.checked.value = sender.state == 1 ? true : false
    }
}

class BoolWrapper : NSObject{
    var value : Bool
    init(_ bool: Bool) {
        value = bool
    }
}
