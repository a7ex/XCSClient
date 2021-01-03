//
//  CDTrigger+Codable.swift
//  XCSClient
//
//  Created by Alex da Franca on 27.12.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import Foundation
import CoreData

extension CDTrigger {
    func update(with trigger: Trigger) {
        name = trigger.name
        phaseValue = Int16(trigger.phase?.rawValue ?? 0)
        scriptBody = trigger.scriptBody
        type = Int16(trigger.type ?? 0)
        
        if let conds = trigger.conditions  {
            if let context = managedObjectContext {
                let newConds = conditions ?? CDTriggerConditions(context: context)
                newConds.update(with: conds)
                conditions = newConds
            } else {
                fatalError("Wir haben hier keinen context!!")
            }
        } else {
            conditions = nil
        }
        
        if let config = trigger.emailConfiguration  {
            if let context = managedObjectContext {
                let newConfig = emailConfiguration ?? CDEmailConfiguration(context: context)
                newConfig.update(with: config)
                emailConfiguration = newConfig
            } else {
                fatalError("Wir haben hier keinen context!!")
            }
        } else {
            emailConfiguration = nil
        }
    }
}

extension CDTrigger {
    var asCodableObject: Trigger {
        return Trigger(
            name: name,
            conditions: conditions?.asCodableObject,
            phase: TriggerPhase(rawValue: Int(phaseValue)),
            scriptBody: scriptBody,
            type: Int(type),
            emailConfiguration: emailConfiguration?.asCodableObject
        )
    }
}
