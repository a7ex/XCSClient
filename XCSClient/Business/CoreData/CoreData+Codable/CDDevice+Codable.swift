//
//  CDDevice+Codable.swift
//  XCSClient
//
//  Created by Alex da Franca on 04.07.21.
//  Copyright © 2021 Farbflash. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObjectContext {
    @discardableResult
    func device(from device: Device) -> CDTestDevice? {
        guard let itemId = device.id else {
            return nil
        }
        let request: NSFetchRequest<CDTestDevice> = CDTestDevice.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", itemId)
        do {
            let items = try fetch(request)
            guard let newItem = items.first else {
                return createAndInsert(device: device)
            }
            newItem.update(with: device)
            return newItem
        } catch {
            return createAndInsert(device: device)
        }
    }
    
    func deviceName(for deviceIdentifier: String) -> String? {
        guard let device = device(with: deviceIdentifier) else {
            return nil
        }
        return device.name
    }
    
    func device(with deviceIdentifier: String) -> CDTestDevice? {
        let request: NSFetchRequest<CDTestDevice> = CDTestDevice.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", deviceIdentifier)
        do {
            let items = try fetch(request)
            return items.first
        } catch {
            return nil
        }
    }
    
    private func createAndInsert(device: Device) -> CDTestDevice {
        let newItem = CDTestDevice(context: self)
        newItem.update(with: device)
        insert(newItem)
        return newItem
    }
}

extension CDTestDevice {
    func update(with device: Device) {
        id = device.id
        name = device.name
        identifier = device.identifier
        udid = device.udid
        type = device.type
        model = device.model
        os = device.os
        platform = device.platform
        simulator = device.simulator ?? false
        if let additional = device.additionalInfos.first,
           additional.contains("Apple Watch") {
        pairedWatch = additional
        } else {
            pairedWatch = ""
        }
    }
}
