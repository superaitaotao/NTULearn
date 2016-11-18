//
//  SettingStackView.swift
//  NewNTULearn
//
//  Created by shutao xu on 9/11/16.
//  Copyright © 2016 shutao xu. All rights reserved.
//

import Cocoa

class SettingStackRow{
    
    let stackRow: NSStackView
    let checkBox: NSButton
    let textView: NSTextField
    var checked: BoolWrapper
    
    init(checked: BoolWrapper, text: String, fontsize: Int, leftPadding: Int, rowHeight: Int, rowWidth: Int) {
        
        let checkBox = NSButton(checkboxWithTitle: "", target: nil, action: nil)
        let textView = NSTextField()
        let checked = checked
        
        checkBox.title = ""
        checkBox.state = checked.value ? 1 : 0
        
        
        textView.isEditable = false
        textView.font = NSFont.systemFont(ofSize: CGFloat(fontsize))
        textView.stringValue = text
        textView.allowsEditingTextAttributes = true
        
        textView.backgroundColor = NSColor(calibratedRed: 0, green: 0, blue: 0, alpha: 0)
        textView.isBordered = false
        textView.drawsBackground = true
  
        let stackRow = NSStackView(views: [checkBox, textView])
        stackRow.orientation = .horizontal
        checkBox.leftAnchor.constraint(equalTo: stackRow.leftAnchor, constant: CGFloat(leftPadding)).isActive = true
        textView.leftAnchor.constraint(equalTo: checkBox.rightAnchor, constant: 10).isActive = true
        stackRow.heightAnchor.constraint(equalToConstant: CGFloat(rowHeight)).isActive = true
        stackRow.widthAnchor.constraint(equalToConstant: CGFloat(rowWidth)).isActive = true
        
        self.checkBox = checkBox
        self.stackRow = stackRow
        self.textView = textView
        self.checked = checked
        self.checkBox.target = self
        self.checkBox.action = #selector(onCheckboxChanged(sender:))
    }
    
    @IBAction func onCheckboxChanged(sender: NSButton) {
        checked.value = sender.state == 1 ? true : false
    }

    func get() -> NSStackView{
        return stackRow
    }
}

class BoolWrapper : NSObject{
    var value : Bool
    init(_ bool: Bool) {
        value = bool
    }
}
