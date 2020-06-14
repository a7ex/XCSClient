//
//  BotVM.swift
//  XCSClient
//
//  Created by Alex da Franca on 14.06.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import Foundation

struct BotVM {
    let botModel: Bot
    
    var id: String {
        return botModel.id ?? UUID().uuidString
    }
    var tinyID: String {
        return botModel.tinyID ?? "- missing -"
    }
    var name: String {
        return botModel.name
    }
    var integrationCounter: Int {
        return botModel.integrationCounter ?? 0
    }
    var performsAnalyzeAction: Bool {
        return botModel.configuration?.performsAnalyzeAction ?? false
    }
    var performsTestAction: Bool {
        return botModel.configuration?.performsTestAction ?? false
    }
    var performsArchiveAction: Bool {
        return botModel.configuration?.performsArchiveAction ?? false
    }
    var performsUpgradeIntegration: Bool {
        return botModel.configuration?.performsUpgradeIntegration ?? false
    }
    
    init(bot: Bot) {
        botModel = bot
    }
}
