//
//  SimpleTextViewController.swift
//  XCSClient
//
//  Created by Alex da Franca on 19.06.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import Cocoa

class SimpleTextViewController: NSViewController {
    var stringContent: String? {
        didSet {
            guard view.superview != nil else {
                return
            }
            textView.string = stringContent ?? ""
        }
    }
    @IBOutlet private var textView: NSTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        if let content = stringContent {
            textView.string = content
        }
    }
    
}
