//
//  IntegrationListItemVM.swift
//  XCSClient
//
//  Created by Alex da Franca on 14.06.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import SwiftUI

struct IntegrationListItemVM: ExpandableBotListItem {
    let integration: IntegrationVM
    let type = ListviewModelType.integration
    let isExpandable = false
    var isExpanded = false
    
    var id: String {
        return integration.id
    }
    
    var title: String {
        return integration.tinyID
    }
    
    var destination: AnyView {
        AnyView(IntegrationDetailView(integration: integration))
    }
}
