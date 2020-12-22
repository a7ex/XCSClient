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
        return bot.id
    }
    
    var title: String {
        return bot.name
    }
    
    var destination: AnyView {
        AnyView(BotDetailView(bot: bot))
    }
    
    var statusColor: Color {
        return Color.primary
    }
    
    var searchableContent: String {
        return title.lowercased()
    }
}
