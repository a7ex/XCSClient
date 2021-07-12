//
//  Colors.swift
//  XCSClient
//
//  Created by Alex da Franca on 03.01.21.
//  Copyright © 2021 Farbflash. All rights reserved.
//

import SwiftUI

struct Colors {
    static let inProgress = NSColor.white
    static let online = success
    static let offline = NSColor.systemRed
    
    static let warning = NSColor.systemOrange
    static let error = NSColor.systemRed
    static let canceled = NSColor.systemGray
    static let success = NSColor(red: 76/255.0, green: 175/255.0, blue: 80/255.0, alpha: 1.0)
    static let testFailures = NSColor.systemPurple
    
    static let lightBackground = NSColor(deviceWhite: 0.96, alpha: 1.0)
}

extension Color {
    static let inProgress = Color(Colors.inProgress)
    static let online = Color(Colors.online)
    static let offline = Color(Colors.offline)
    
    static let warning = Color(Colors.warning)
    static let error = Color(Colors.error)
    static let canceled = Color(Colors.canceled)
    static let success = Color(Colors.success)
    static let testFailures = Color(Colors.testFailures)
    
    static let lightBackground = Color(Colors.lightBackground)
}
