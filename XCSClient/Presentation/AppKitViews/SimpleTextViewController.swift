//
//  SimpleTextViewController.swift
//  XCSClient
//
//  Created by Alex da Franca on 19.06.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import Cocoa

class SimpleTextViewController: NSViewController, NSWindowDelegate {
    
    @IBOutlet private var textView: NSTextView!
    
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
    private var uploadClosure: ((String) -> Void)?
    private let fileHelper = FileHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        if let content = stringContent {
            textView.string = content
        }
        textView.isEditable = editableText
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        self.view.window?.delegate = self
    }
    
    private var alert: NSAlert?

    func windowShouldClose(_ sender: NSWindow) -> Bool {
        let newText = textView.string
        if newText == stringContent {
            return true
        } else {
            let alrt = NSAlert()
            alrt.addButton(withTitle: "Upload settings")
            alrt.addButton(withTitle: "Cancel")
            alrt.messageText = "Do you want to upload changes to the server?"
            alrt.beginSheetModal(for: view.window!) { [weak self] (result) in
                switch result {
                case .alertFirstButtonReturn:
                    self?.uploadClosure?(newText)
                    self?.view.window?.close()
                default:
                    self?.view.window?.close()
                }
            }
            alert = alrt
            return false
        }
    }
    
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
    
    func onUploadChanges(completion: @escaping (String) -> Void) {
        uploadClosure = completion
    }
}
