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
    var saveAlertMessage = "Do you want to save changes? Note, that you still need to upload the changes to the server."
    var saveAlertInfoText = ""
    
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
            alrt.addButton(withTitle: "Save Changes")
            alrt.addButton(withTitle: "Cancel")
            alrt.messageText = saveAlertMessage
            alrt.informativeText = saveAlertInfoText
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
