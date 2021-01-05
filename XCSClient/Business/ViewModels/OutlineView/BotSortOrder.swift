//
//  BotSortOrder.swift
//  XCSClient
//
//  Created by Alex da Franca on 05.01.21.
//  Copyright © 2021 Farbflash. All rights reserved.
//

import Foundation

enum BotSortOrder {
    case alphabetical, chronological
    
    var string: String {
        switch self {
        case .alphabetical:
            return "Alphabetical"
        case .chronological:
            return "Chronological"
        }
    }
}
