//
//  Trigger.swift
//  xcodeserverclient
//
//  Created by Alex da Franca on 04.06.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import Foundation

struct Trigger: Codable {
    var name: String?
    var conditions: TriggerConditions? // must be set, if phase == after
    var phase: TriggerPhase?
    var scriptBody: String?
    var type: Int?
    var emailConfiguration: EmailConfiguration?
}
