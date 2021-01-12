//
//  CDServer+Outline.swift
//  XCSClient
//
//  Created by Alex da Franca on 25.12.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import SwiftUI

extension CDServer: OutlineElement {
    
    var children: [OutlineElement]? {
        let bots = items as? Set<CDBot> ?? []
        switch botSortOrder {
        case .byName:
            return Array(bots)
                .sorted { ($0.name ?? "") < ($1.name ?? "") }
        case .byDate:
            return Array(bots)
                .sorted { ($0.lastEventDate) > ($1.lastEventDate) }
        case .byStatus:
            return Array(bots)
                .sorted {
                    guard $0.sortedStatus != $1.sortedStatus else {
                        return ($0.name ?? "") < ($1.name ?? "")
                    }
                    return ($0.sortedStatus) < ($1.sortedStatus)
                }
        }
        
    }
    
    var title: String {
        return name ?? ""
    }
    
    var statusColor: Color {
        let reachab = ServerReachabilty(rawValue: Int(reachability)) ?? .unknown
        switch reachab {
        case .unknown:
            return .clear
        case .connecting:
            return Color(Colors.inProgress)
        case .reachable:
            return Color(Colors.online)
        case .unreachable:
            return Color(Colors.offline)
        }
    }
    
    var destination: AnyView {
        AnyView(CDServerView(serverID: self.id ?? ""))
    }
    
    var systemIconName: String {
        return "tv.fill"
    }
    
    var botSortOrder: BotSortOrder {
        get {
            return BotSortOrder(rawValue: Int(botSortOrderInt)) ?? .byName
        }
        set {
            botSortOrderInt = Int16(newValue.rawValue)
        }
    }
}
