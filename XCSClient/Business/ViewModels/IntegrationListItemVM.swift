//
//  IntegrationListItemVM.swift
//  XCSClient
//
//  Created by Alex da Franca on 14.06.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import SwiftUI

struct IntegrationListItemVM: BotListItem {
    let integration: IntegrationVM
    let type = ListviewModelType.integration
    var items: [BotListItem]?
    
    var id: String {
        return integration.id
    }
    
    var title: String {
        return integration.listTitle
    }
    
    var destination: AnyView {
        AnyView(IntegrationDetailView(integration: integration))
    }
    
    var statusColor: Color {
        return integration.statusColor
    }
    
    var searchableContent: String {
        return integration.bot?.name.lowercased() ?? ""
    }
}
