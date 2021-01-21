//
//  IntegrationUpdateWorker.swift
//  XCSClient
//
//  Created by Alex da Franca on 02.01.21.
//  Copyright © 2021 Farbflash. All rights reserved.
//

import Foundation

class IntegrationUpdateWorker {
    private static let instance = IntegrationUpdateWorker()
    private var updatingBots = Set<BotUpdater>()
    private var timer: Timer?
    
    private init() { }
    
    static func add(_ bot: CDBot) {
        instance.add(bot)
    }
    
    // MARK: Private
    
    private func add(_ bot: CDBot) {
        updatingBots.insert(BotUpdater(bot: bot))
        if timer == nil {
            timer = Timer.scheduledTimer(
                withTimeInterval: 20,
                repeats: true) { [weak self] _ in
                self?.checkForUpdates()
            }
        }
        checkForUpdates()
    }
    
    private func checkForUpdates() {
        for bot in updatingBots {
            checkUpdate(for: bot)
        }
    }
    
    private func checkUpdate(for botUpdater: BotUpdater) {
        guard !botUpdater.isUpdating else {
            return
        }
        let bot = botUpdater.bot
        guard let server = botUpdater.bot.server,
              let context = bot.managedObjectContext else {
            updatingBots.remove(botUpdater)
            return
        }
        botUpdater.isUpdating = true
        server.connector.getIntegrationsList(for: bot.idString, last: 2 ) { [weak self] (result) in
            botUpdater.isUpdating = false
            if case let .success(integrations) = result {
                integrations.forEach { (integration) in
                    let obj = context.integration(from: integration)
                    bot.addToItems(obj)
                }
                if !bot.integrationInProgress {
                    self?.updatingBots.remove(botUpdater)
                }
            } else {
                self?.updatingBots.remove(botUpdater)
            }
            do {
                bot.server?.name = bot.server?.name
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

private class BotUpdater: Hashable {
    let bot: CDBot
    var botId: String {
        bot.idString
    }
    var isUpdating = false
    
    init(bot: CDBot) {
        self.bot = bot
    }
    
    static func == (lhs: BotUpdater, rhs: BotUpdater) -> Bool {
        return lhs.botId == rhs.botId
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(botId)
    }
}
