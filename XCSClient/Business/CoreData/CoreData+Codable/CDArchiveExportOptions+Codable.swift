//
//  CDArchiveExportOptions+Codable.swift
//  XCSClient
//
//  Created by Alex da Franca on 27.12.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import Foundation
import CoreData

extension CDArchiveExportOptions {
    func update(with options: ArchiveExportOptions) {
        name = options.name
        createdAt = options.createdAt
        
        if let expOptions = options.exportOptions {
            if let context = managedObjectContext {
                let newExportOptions = exportOptions ?? CDIPAExportOptions(context: context)
                newExportOptions.update(with: expOptions)
                exportOptions = newExportOptions
            } else {
                fatalError("Wir haben hier keinen context!!")
            }
        } else {
            exportOptions = nil
        }
    }
}

extension CDArchiveExportOptions {
    var asCodableObject: ArchiveExportOptions {
        return ArchiveExportOptions(
            name: name,
            createdAt: createdAt,
            exportOptions: exportOptions?.asCodableObject
        )
    }
}
