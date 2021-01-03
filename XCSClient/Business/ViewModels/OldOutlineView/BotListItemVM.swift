//
//  BotListItemVM.swift
//  XCSClient
//
//  Created by Alex da Franca on 14.06.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import SwiftUI

struct BotListItemVM: BotListItem {
    let bot: BotVM
    var items: [BotListItem]?
    
    let type = ListviewModelType.bot
    
    var id: String {
        return bot.idString
    }
    
    var title: String {
        return bot.nameString
    }
    
    var destination: AnyView {
        AnyView(BotDetailView(bot: bot, changeClosure: { _ in }))
    }
    
    var statusColor: Color {
        if let firstintegration = items?.first as? IntegrationListItemVM {
            return firstintegration.statusColor
        }
        return Color.primary
    }
    
    var searchableContent: String {
        return title.lowercased()
    }
}
