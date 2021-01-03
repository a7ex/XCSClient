//
//  CDPlatform.Codable.swift
//  XCSClient
//
//  Created by Alex da Franca on 27.12.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import Foundation
import CoreData

extension CDPlatform {
    func update(with platform: Platform?) {
        id = id ?? UUID().uuidString
        buildNumber = platform?.buildNumber
        displayName = platform?.displayName
        identifier = platform?.identifier
        rev = platform?.rev
        simulatorIdentifier = platform?.simulatorIdentifier
        version = platform?.version
    }
}

extension CDPlatform {
    var asCodableObject: Platform {
        return Platform(
            id: id,
            rev: rev,
            buildNumber: buildNumber,
            displayName: displayName,
            identifier: identifier,
            simulatorIdentifier: simulatorIdentifier,
            version: version
        )
    }
}
