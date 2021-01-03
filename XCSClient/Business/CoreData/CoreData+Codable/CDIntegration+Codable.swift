//
//  CDIntegration+Codable.swift
//  XCSClient
//
//  Created by Alex da Franca on 27.12.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObjectContext {
    @discardableResult
    func integration(from integration: Integration) -> CDIntegration {
        let request: NSFetchRequest<CDIntegration> = CDIntegration.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", integration.id)
        do {
            let items = try fetch(request)
            guard let newItem = items.first else {
                return createAndInsert(integration: integration)
            }
            newItem.update(with: integration)
            return newItem
        } catch {
            return createAndInsert(integration: integration)
        }
    }
    
    private func createAndInsert(integration: Integration) -> CDIntegration {
        let newItem = CDIntegration(context: self)
        newItem.update(with: integration)
        insert(newItem)
        return newItem
    }
}

extension CDIntegration {
    func update(with integration: Integration) {
        id = integration.id
        ccPercentage = Int16(integration.ccPercentage ?? 0)
        ccPercentageDelta = Int16(integration.ccPercentageDelta ?? 0)
        currentStep = integration.currentStep
        duration = integration.duration ?? 0
        endedTime = integration.endedTime
        number = Int32(integration.number ?? 0)
        queuedDate = integration.queuedDate
        result = integration.result?.rawValue
        startedTime = integration.startedTime
        tinyID = integration.tinyID
        
        if let assts = integration.assets {
            if let context = managedObjectContext {
                let newAssets = CDIntegrationAssets(context: context)
                newAssets.update(with: assts)
                assets = newAssets
            } else {
                fatalError("Wir haben hier keinen context!!")
            }
        } else {
            assets = nil
        }
        
        // bot = integration.bot
        
        if let blsSum = integration.buildResultSummary {
            if let context = managedObjectContext {
                let newResults = CDBuildResultSummary(context: context)
                newResults.update(with: blsSum)
                buildResultSummary = newResults
            } else {
                fatalError("Wir haben hier keinen context!!")
            }
        } else {
            buildResultSummary = nil
        }
        
        items = nil
        
        if let blprnt = integration.revisionBlueprint {
            if let context = managedObjectContext {
                let newBPrint = CDSourceControlBlueprint(context: context)
                newBPrint.update(with: blprnt)
                revisionBlueprint = newBPrint
            } else {
                fatalError("Wir haben hier keinen context!!")
            }
        } else {
            revisionBlueprint = nil
        }
    }
}
