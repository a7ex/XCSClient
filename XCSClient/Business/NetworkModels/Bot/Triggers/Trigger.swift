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
    
    static var startTriggerTemplate: Trigger {
        return Trigger(
            name: "XCSStart",
            conditions: TriggerConditions.allOn,
            phase: .before,
            scriptBody: "#!\\/bin\\/sh\necho \"Running start script. Working directory is: $(pwd)\"",
            type: 1,
            emailConfiguration: nil
        )
    }
    static var endTriggerTemplate: Trigger {
        return Trigger(
            name: "XCSStop",
            conditions: nil,
            phase: .after,
            scriptBody: "#!\\/bin\\/sh\necho \"Running end script. Working directory is: $(pwd)\"",
            type: 1,
            emailConfiguration: nil
        )
    }
}
