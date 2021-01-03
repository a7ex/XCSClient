//
//  DataSyncWorker.swift
//  XCSClient
//
//  Created by Alex da Franca on 01.01.21.
//  Copyright © 2021 Farbflash. All rights reserved.
//

import Foundation
import CoreData

class DataSyncWorker {
    private static let instance = DataSyncWorker()
    private var currentWorker: SyncWorker?
    
    private init() { }
    
    static func updateData(in context: NSManagedObjectContext) {
        instance.startUpdate(in: context)
    }
    
    // MARK: Private
    
    private func startUpdate(in context: NSManagedObjectContext) {
        currentWorker?.cancel()
        currentWorker = SyncWorker(context: context)
    }
}

private class SyncWorker {
    var isDone = false
    
    private let currentContext: NSManagedObjectContext
    private let fetchRequest: NSFetchRequest<CDServer> = CDServer.fetchRequest()
    private var servers = [CDServer]()
    private var serverIterator: IndexingIterator<[CDServer]>
    private var botIterator: IndexingIterator<[CDBot]>
    
    init(context: NSManagedObjectContext) {
        currentContext = context
        serverIterator = servers.makeIterator()
        botIterator = [CDBot]().makeIterator()
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \CDServer.name, ascending: true)]
        loadAllBots(in: context)
    }
    
    func cancel() {
        isDone = true
    }
    
    // MARK: Private
    
    private func loadAllBots(in context: NSManagedObjectContext) {
        do {
            servers = try currentContext.fetch(fetchRequest)
            for server in servers {
                server.reachability = Int16(ServerReachabilty.unknown.rawValue)
            }
            serverIterator = servers.makeIterator()
            loadNextBotlist()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func loadNextBotlist() {
        guard !isDone else { return }
        guard let server = serverIterator.next() else {
            refreshAllIntegrations()
            return
        }
        server.reachability = Int16(ServerReachabilty.connecting.rawValue)
        server.connector.getBotList { [weak self] (result) in
            guard let done = self?.isDone,
                  !done else {
                return
            }
            if case let .success(bots) = result {
                bots.forEach { (bot) in
                    if let bot = self?.currentContext.bot(from: bot) {
                        server.addToItems(bot)
                    }
                }
                server.reachability = Int16(ServerReachabilty.reachable.rawValue)
            } else {
                server.reachability = Int16(ServerReachabilty.unreachable.rawValue)
            }
            defer {
                self?.loadNextBotlist()
            }
            do {
                try self?.currentContext.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    private func refreshAllIntegrations() {
        guard !isDone else { return }
        serverIterator = servers.makeIterator()
        refreshNextServerIntegrations()
    }
    
    private func refreshNextServerIntegrations() {
        guard !isDone else { return }
        guard let server = serverIterator.next() else {
            return
        }
        guard let bots = server.items else {
            refreshNextServerIntegrations()
            return
        }
        botIterator = (Array(bots) as! [CDBot]).makeIterator()
        refreshNextBotIntegrations()
    }
    
    private func refreshNextBotIntegrations() {
        guard !isDone else { return }
        guard let bot = botIterator.next(),
              let server = bot.server else {
            refreshNextServerIntegrations()
            return
        }
        server.connector.getIntegrationsList(for: bot.idString, last: 2) { [weak self] (result) in
            guard let done = self?.isDone,
                  !done else {
                return
            }
            if case let .success(integrations) = result {
                integrations.forEach { (integration) in
                    if let obj = self?.currentContext.integration(from: integration) {
                        bot.addToItems(obj)
                    }
                }
            }
            defer {
                self?.refreshNextBotIntegrations()
            }
            do {
                try self?.currentContext.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
