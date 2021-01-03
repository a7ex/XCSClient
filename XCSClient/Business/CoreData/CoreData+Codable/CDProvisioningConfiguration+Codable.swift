//
//  CDProvisioningConfiguration+Codable.swift
//  XCSClient
//
//  Created by Alex da Franca on 27.12.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import Foundation
import CoreData

extension CDProvisioningConfiguration {
    func update(with config: ProvisioningConfiguration) {
        addMissingDevicesToTeams = config.addMissingDevicesToTeams ?? false
        manageCertsAndProfiles = config.manageCertsAndProfiles ?? false
    }
}

extension CDProvisioningConfiguration {
    var asCodableObject: ProvisioningConfiguration {
        return ProvisioningConfiguration(
            addMissingDevicesToTeams: addMissingDevicesToTeams,
            manageCertsAndProfiles: manageCertsAndProfiles
        )
    }
}
