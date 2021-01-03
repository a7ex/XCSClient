//
//  CDIPAExportOptions+Codable.swift
//  XCSClient
//
//  Created by Alex da Franca on 27.12.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import Foundation
import CoreData

extension CDIPAExportOptions {
    func update(with options: IPAExportOptions) {
        compileBitcode = options.compileBitcode ?? false
        destination = options.destination
        method = options.method
        provisioningProfiles = options.provisioningProfiles
        signingCertificate = options.signingCertificate
        signingStyle = options.signingStyle
        stripSwiftSymbols = options.stripSwiftSymbols ?? false
        teamID = options.teamID
        thinning = options.thinning 
    }
}

extension CDIPAExportOptions {
    var asCodableObject: IPAExportOptions {
        return IPAExportOptions(
            compileBitcode: compileBitcode,
            destination: destination,
            method: method,
            provisioningProfiles: provisioningProfiles,
            signingCertificate: signingCertificate,
            signingStyle: signingStyle,
            stripSwiftSymbols: stripSwiftSymbols,
            teamID: teamID,
            thinning: thinning
        )
    }
}
