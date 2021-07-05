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
    
    private var queue = OperationQueue()
    
    init(context: NSManagedObjectContext) {
        currentContext = context
        serverIterator = servers.makeIterator()
        
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
                server.synchronize(with: bots)
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
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.refreshNextServerIntegrations()
        }
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
        
        queue = OperationQueue()
        queue.maxConcurrentOperationCount = 8 //Deadlock if this is = 1
        queue.qualityOfService = .userInitiated
        
        bots.compactMap { $0 as? CDBot }
        .forEach { bot in
            bot.updateInProgress = true
            queue.addOperation { [weak self] in
                self?.refreshIntegrations(of: bot)
            }
        }
        queue.waitUntilAllOperationsAreFinished()
        refreshNextServerIntegrations()
    }
    
    private func refreshIntegrations(of bot: CDBot) {
        guard let server = bot.server else {
            return
        }
        server.connector.getIntegrationsList(for: bot.idString, last: 2) { [weak self] (result) in
            bot.updateInProgress = false
            bot.server?.name = bot.server?.name // force update of outline list
            
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
            do {
                try self?.currentContext.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
