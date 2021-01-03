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
        return Array(bots)
            .sorted { ($0.name ?? "") < ($1.name ?? "") }
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
            return .yellow
        case .reachable:
            return .green
        case .unreachable:
            return .red
        }
    }
    
    var destination: AnyView {
        AnyView(CDServerView(serverID: self.id ?? ""))
    }
}
