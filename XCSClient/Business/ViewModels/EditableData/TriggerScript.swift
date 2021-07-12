//
//  TriggerScript.swift
//  XCSClient
//
//  Created by Alex da Franca on 12.07.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import Foundation

struct TriggerScript: Equatable {
    let name: String
    let script: String
    
    init?(name: String?, script: String?) {
        guard let name = name,
            !name.isEmpty,
            let script = script,
            !script.isEmpty else {
                return nil
        }
        self.name = name
        self.script = script
    }
}

extension CDTrigger {
    var asTriggerScript: TriggerScript? {
        return TriggerScript(
            name: name,
            script: scriptBody
        )
    }
}
