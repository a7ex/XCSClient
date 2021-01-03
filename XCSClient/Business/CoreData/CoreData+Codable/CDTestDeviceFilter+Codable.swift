//
//  CDTestDeviceFilter+Codable.swift
//  XCSClient
//
//  Created by Alex da Franca on 27.12.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import Foundation
import CoreData

extension CDTestDeviceFilter {
    func update(with filter: TestDeviceFilter) {
        architectureType = Int16(filter.architectureType ?? 0)
        filterType = Int16(filter.filterType ?? 0)
        
        if let context = managedObjectContext {
            platform = platform ?? CDPlatform(context: context)
            platform?.update(with: filter.platform)
        } else {
            fatalError("Wir haben hier keinen context!!")
        }
    }
}

extension CDTestDeviceFilter {
    var asCodableObject: TestDeviceFilter {
        return TestDeviceFilter(
            architectureType: Int(architectureType),
            filterType: Int(filterType),
            platform: platform?.asCodableObject
        )
    }
}
