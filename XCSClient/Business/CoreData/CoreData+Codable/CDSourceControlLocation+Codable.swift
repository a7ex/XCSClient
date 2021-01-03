//
//  CDSourceControlLocation+Codable.swift
//  XCSClient
//
//  Created by Alex da Franca on 27.12.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import Foundation
import CoreData

extension CDSourceControlLocation {
    func update(with location: SourceControlLocation) {
        branchIdentifierKey = location.branchIdentifierKey
        branchOptionsKeyValue = Int16(location.branchOptionsKey?.rawValue ?? 0)
        locationRevisionKey = location.locationRevisionKey
        pathIdentifierKey = location.pathIdentifierKey
        workspaceBlueprintLocationTypeKeyValue = location.workspaceBlueprintLocationTypeKey?.rawValue
    }
}

extension CDSourceControlLocation {
    var asCodableObject: SourceControlLocation {
        return SourceControlLocation(
            branchIdentifierKey: branchIdentifierKey,
            branchOptionsKey: BranchOptionsKey(rawValue: Int(branchOptionsKeyValue)),
            workspaceBlueprintLocationTypeKey: WorkspaceBlueprintLocationType(rawValue: workspaceBlueprintLocationTypeKeyValue ?? ""),
            pathIdentifierKey: pathIdentifierKey,
            locationRevisionKey: locationRevisionKey
        )
    }
}
