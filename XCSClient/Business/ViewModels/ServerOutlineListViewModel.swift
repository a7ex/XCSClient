//
//  ServerOutlineListViewModel.swift
//  XCSClient
//
//  Created by Alex da Franca on 17.01.21.
//  Copyright © 2021 Farbflash. All rights reserved.
//

import Foundation

struct ServerOutlineListViewModel {
    func refreshIntegrationStatus(of item: OutlineElement) {
        guard let bot = item as? CDBot else {
            return
        }
        IntegrationUpdateWorker.add(bot)
    }
    
    func changeNumberOfVisibleIntegrations(of model: ShowMoreLessCellModel, change: Int) {
        model.bot.visibleItemsCount += change
        saveContextAndRefresh(model.bot.server)
    }
    
    func showAllIntegrations(of model: ShowMoreLessCellModel) {
        model.bot.visibleItemsCount = model.bot.integrationCounterInt - 1
        saveContextAndRefresh(model.bot.server)
    }
    
    func resetNumberOfVisibleIntegrations(of model: ShowMoreLessCellModel) {
        resetNumberOfVisibleIntegrations(of: model.bot)
    }
    
    func resetNumberOfVisibleIntegrations(of model: ShowLessCellModel) {
        resetNumberOfVisibleIntegrations(of: model.bot)
    }
    
    func resetNumberOfVisibleIntegrations(of bot: CDBot) {
        bot.visibleItemsCount = 2
        saveContextAndRefresh(bot.server)
    }
    
    private func saveContextAndRefresh(_ server: CDServer?) {
        guard let server = server else {
            return
        }
        let serverName = server.name
        server.name = serverName
        guard let ctx = server.managedObjectContext else {
            return
        }
        do {
            try ctx.save()
        } catch {
            print("ServerOutlineList error: \(error.localizedDescription)")
        }
        
    }
}
