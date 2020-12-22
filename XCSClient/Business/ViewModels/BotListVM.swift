//
//  BotListVM.swift
//  XCSClient
//
//  Created by Alex da Franca on 14.06.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import Foundation

class BotListVM: ObservableObject {
    @Published var items = [BotListItem]()
    
    var allItems = [BotListItem]() {
        didSet {
            items = filteredItems
        }
    }
    
    var searchQuery = "" {
        didSet {
            searchQuery = searchQuery.lowercased()
            items = filteredItems
        }
    }
    
    var filteredItems: [BotListItem] {
        return allItems.filter { item in
            guard searchQuery.count > 2 else {
                return true
            }
            return  item.searchableContent.contains(searchQuery)
        }
    }
    
    func insertIntegrations(for id: String, integrations: [IntegrationVM]) {
        guard var bot = allItems.first(where: { $0.id == id }) else {
            return
        }
        bot.items = integrations.map({ IntegrationListItemVM(integration: $0) })
        allItems = allItems
            .replacingItem(with: id, newItem: bot)
    }
}

private extension Array where Element == BotListItem {
    func replacingItem(with id: String, newItem: BotListItem) -> [BotListItem] {
        var tmp = self
        guard let pos = tmp.firstIndex(where: { $0.id == id }) else {
            return self
        }
        tmp.remove(at: pos)
        tmp.insert(newItem, at: pos)
        return  tmp
    }
}
