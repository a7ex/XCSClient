//
//  BuiltFromClean.swift
//  XCSClient
//
//  Created by Alex da Franca on 21.06.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import Foundation

enum BuiltFromClean: Int, Codable {
    case never = 0
    case always, onceADay, onceAWeek
}
