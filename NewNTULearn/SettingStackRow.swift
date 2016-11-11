//
//  SettingStackView.swift
//  NewNTULearn
//
//  Created by shutao xu on 9/11/16.
//  Copyright © 2016 shutao xu. All rights reserved.
//

import Cocoa

class SettingStackRow{

    let checkBox: NSButton = NSButton(checkboxWithTitle: "", target: nil, action: nil)
//    let checkBox: NSButton = NSButton(frame: CGRect(x: 10, y: 10, width: 10, height: 10))
    let textView: NSTextField = NSTextField()
    var checked: Bool = false
    
    func getTableRow(checked: inout Bool, text: String, fontsize: Int, leftPadding: Int, rowHeight: Int) -> NSStackView{
        self.checked = checked
        
        checkBox.state = {() -> Int
            in if checked {
                return 1
            } else {
                return 0
            }
        }()
        
        checkBox.title = ""
        checkBox.target = self
        checkBox.action = #selector(onCheckboxChanged(sender:))
        
        textView.isEditable = false
        textView.font = NSFont.systemFont(ofSize: CGFloat(fontsize))
        textView.stringValue = text
        textView.allowsEditingTextAttributes = true
        
        textView.backgroundColor = NSColor(calibratedRed: 0, green: 0, blue: 0, alpha: 0)
        textView.isBordered = false
        textView.drawsBackground = true
        
        let stackView = NSStackView(views: [checkBox, textView])
        checkBox.leftAnchor.constraint(equalTo: stackView.leftAnchor, constant: CGFloat(leftPadding)).isActive = true
        textView.leftAnchor.constraint(equalTo: checkBox.rightAnchor, constant: 10).isActive = true
        stackView.heightAnchor.constraint(equalToConstant: CGFloat(rowHeight)).isActive = true
        
        return stackView
    }
    
    @IBAction func onCheckboxChanged(sender: NSButton) {
        self.checked = { () -> Bool in
            if sender.state == 1 {
                return true
            } else {
                return false
            }
        }()
    }
    
    
}

