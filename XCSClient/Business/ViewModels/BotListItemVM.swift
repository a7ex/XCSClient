//
//  BotListItemVM.swift
//  XCSClient
//
//  Created by Alex da Franca on 14.06.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import SwiftUI

struct BotListItemVM: ExpandableBotListItem {
    let bot: BotVM
    var isExpanded: Bool
    
    let type = ListviewModelType.bot
    let isExpandable = true
    
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
}
