//
//  SimpleTextViewController.swift
//  XCSClient
//
//  Created by Alex da Franca on 19.06.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import Cocoa

class SimpleTextViewController: NSViewController {
    
    private let fileHelper = FileHelper()
    
    @IBAction func saveMenuAction(_ sender: Any) {
        guard let url = fileHelper.getSaveURLFromUser(for: view.window?.title ?? "Untitled.log") else {
            return
        }
        let log = Data(textView.string.utf8)
        do {
            try log.write(to: url)
        } catch {
               _ = NSAlert(error: error).runModal()
        }
    }
    
    var stringContent: String? {
        didSet {
            guard view.superview != nil else {
                return
            }
            textView.string = stringContent ?? ""
        }
    }
    var editableText: Bool = false {
        didSet {
            guard view.superview != nil else {
                return
            }
            textView.isEditable = editableText
        }
    }
    @IBOutlet private var textView: NSTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        if let content = stringContent {
            textView.string = content
        }
        textView.isEditable = editableText
    }
    
}
