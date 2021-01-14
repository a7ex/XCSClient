//
//  CDBot+Codable.swift
//  XCSClient
//
//  Created by Alex da Franca on 27.12.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObjectContext {
    @discardableResult
    func bot(from bot: Bot) -> CDBot? {
        guard let botId = bot.id else {
            return nil
        }
        let request: NSFetchRequest<CDBot> = CDBot.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", botId)
        do {
            let items = try fetch(request)
            guard let newItem = items.first else {
                return createAndInsert(bot: bot)
            }
            newItem.update(with: bot)
            return newItem
        } catch {
            return createAndInsert(bot: bot)
        }
    }
    
    private func createAndInsert(bot: Bot) -> CDBot {
        let newItem = CDBot(context: self)
        newItem.update(with: bot)
        insert(newItem)
        return newItem
    }
}

extension CDBot {
    func update(with bot: Bot) {
        id = bot.id ?? UUID().uuidString
        integrationCounter = Int64(bot.integrationCounter ?? 0)
        name = bot.name
        tinyID = bot.tinyID
        rev = bot.rev
        
        if let config = bot.configuration {
            if let context = managedObjectContext {
                configuration = configuration ?? CDBotConfiguration(context: context)
                configuration?.update(with: config)
            } else {
                fatalError("Wir haben hier keinen context!!")
            }
        } else {
            configuration = nil
        }
    }
}

extension CDBot {
    var asCodableObject: Bot {
        return Bot(
            id: id,
            rev: rev,
            configuration: configuration?.asCodableObject,
            name: name ?? "Untitled",
            tinyID: tinyID,
            docType: nil,
            type: nil,
            group: nil,
            integrationCounter: Int(integrationCounter),
            lastRevisionBlueprint: nil,
            sourceControlBlueprintIdentifier: nil,
            requiresUpgrade: nil,
            duplicatedFrom: nil
        )
    }
}

extension CDBot {
    func updateIntegrationsFromBackend() {
        guard let connector = server?.connector else {
            return
        }
        connector.getIntegrationsList(for: idString, last: visibleItemsCount) { [weak self] (result) in
            guard let self = self else { return }
            if case let .success(integrations) = result {
                integrations.forEach { (integration) in
                    if let obj = self.managedObjectContext?.integration(from: integration) {
                        self.addToItems(obj)
                    }
                }
            }
            // refresh the hierarchical list by making a dummy change
            // to the top level object, CDServer
            self.server?.name = self.server?.name
            do {
                try self.managedObjectContext?.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
