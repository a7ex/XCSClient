//
//  CDServer+Synchronizable.swift
//  XCSClient
//
//  Created by Alex da Franca on 04.07.21.
//  Copyright © 2021 Farbflash. All rights reserved.
//

import Foundation
import CoreData

extension CDServer {
    func synchronize(with bots: [Bot]) {
        bots.forEach { (bot) in
            if let bot = managedObjectContext?.bot(from: bot) {
                addToItems(bot)
            }
        }
        guard let serverId = id,
              let moc = managedObjectContext else {
            return
        }
        let ids = bots.compactMap { $0.id }
        let request: NSFetchRequest<CDBot> = CDBot.fetchRequest()
        let onlyMembers = NSPredicate(format: "server.id == %@", serverId)
        let notOnServer = NSPredicate(format: "NOT (id IN %@)", ids)
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [onlyMembers, notOnServer])
        if let items = try? moc.fetch(request),
           !items.isEmpty {
            for item in items {
                moc.delete(item)
            }
            do {
                try moc.save()
            } catch {
                print("Error during save of bot synchronization!")
            }
        }
    }
}
