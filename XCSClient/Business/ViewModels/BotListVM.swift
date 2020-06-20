//
//  BotListVM.swift
//  XCSClient
//
//  Created by Alex da Franca on 14.06.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import Foundation

class BotListVM: ObservableObject {
    @Published var items = [ExpandableBotListItem]()
    
    func collapseIntegrations(of id: String) {
        guard var bot = items.first(where: { $0.id == id }) else {
            return
        }
        bot.isExpanded = false
        items = items
            .replacingItem(with: id, newItem: bot)
            .removingIntegrations(of: id)
    }
    
    func expandIntegrations(for id: String, integrations: [IntegrationVM]) {
        guard var bot = items.first(where: { $0.id == id }) else {
            return
        }
        bot.isExpanded = true
        items = items
            .replacingItem(with: id, newItem: bot)
            .addingIntegrations(for: id, integrations: integrations)
    }
}

private extension Array where Element == ExpandableBotListItem {
    func replacingItem(with id: String, newItem: ExpandableBotListItem) -> [ExpandableBotListItem] {
        var tmp = self
        guard let pos = tmp.firstIndex(where: { $0.id == id }) else {
            return self
        }
        tmp.remove(at: pos)
        tmp.insert(newItem, at: pos)
        return  tmp
    }
    
    func removingIntegrations(of id: String) -> [ExpandableBotListItem] {
        var tmp = self
        guard let pos = tmp.firstIndex(where: { $0.id == id }) else {
            return self
        }
        let first = pos + 1
        var last = first
        while last < tmp.count,
            tmp[last] is IntegrationListItemVM {
                last += 1
        }
        last -= 1
        guard last >= first else {
            return self
        }
        tmp.replaceSubrange(first...last, with: [])
        return tmp
    }
    
    func addingIntegrations(for id: String, integrations: [IntegrationVM]) -> [ExpandableBotListItem] {
        var tmp = removingIntegrations(of: id)
        
        guard let pos = tmp.firstIndex(where: { $0.id == id }) else {
            return tmp
        }
        
        tmp.insert(contentsOf: integrations.map { IntegrationListItemVM(integration: $0) }, at: pos+1)
        return tmp
    }
}
