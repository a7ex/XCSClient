//
//  BotSortOrder.swift
//  XCSClient
//
//  Created by Alex da Franca on 05.01.21.
//  Copyright © 2021 Farbflash. All rights reserved.
//

import Foundation

enum BotSortOrder: Int, CaseIterable {
    case byName, byDate, byStatus
    
    var string: String {
        switch self {
        case .byName:
            return "By name"
        case .byDate:
            return "By date"
        case .byStatus:
            return "By status"
        }
    }
}
