//
//  Windows.swift
//  XCSClient
//
//  Created by Alex da Franca on 14.06.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import SwiftUI

extension NSWindow {
    static var login: NSWindow {
        let windowRef = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 300, height: 200),
            styleMask: [.titled, .resizable],
            backing: .buffered,
            defer: false
        )
        let loginView = LoginView(window: windowRef)
        windowRef.contentView = NSHostingView(rootView: loginView)
        windowRef.center()
        return windowRef
    }
    
    static var botList: NSWindow {
        let windowRef = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 740, height: 480),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        let screenHeight = NSScreen.main?.frame.size.height ?? 0
        windowRef.setFrame(
            NSRect(x: 50, y: screenHeight - 530, width: 740, height: 480),
            display: true
        )
        return windowRef
    }
}
