//
//  AppDelegate.swift
//  XCSClient
//
//  Created by Alex da Franca on 12.06.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import SwiftUI

@main
struct XCSClientApp: App {
    let window = NSWindow(
        contentRect: NSRect(x: 0, y: 0, width: 800, height: 600),
        styleMask: [.titled, .resizable],
        backing: .buffered, defer: false
    )
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            MainView() // LoginView(window: window)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

