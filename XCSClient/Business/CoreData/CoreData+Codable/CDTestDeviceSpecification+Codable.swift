//
//  CDTestDeviceSpecification+Codable.swift
//  XCSClient
//
//  Created by Alex da Franca on 27.12.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import Foundation
import CoreData

extension CDTestDeviceSpecification {
    func update(with deviceSpecification: TestDeviceSpecification) {
        deviceIdentifiers = deviceSpecification.deviceIdentifiers
        if let fltrs = filters {
            removeFromFilters(fltrs)
        }
        if let context = managedObjectContext {
            deviceSpecification.filters?.forEach { input in
                let newFilter = CDTestDeviceFilter(context: context)
                newFilter.update(with: input)
                addToFilters(newFilter)
            }
        } else {
            fatalError("Wir haben hier keinen context!!")
        }
    }
}

extension CDTestDeviceSpecification {
    var asCodableObject: TestDeviceSpecification {
        let testDeviceFilterArray = Array(filters ?? NSSet()) as? [CDTestDeviceFilter]
        return TestDeviceSpecification(
            deviceIdentifiers: deviceIdentifiers,
            filters: testDeviceFilterArray?.map { $0.asCodableObject}
        )
    }
}
