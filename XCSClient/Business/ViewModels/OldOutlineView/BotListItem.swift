//
//  ExpandableBotList.swift
//  XCSClient
//
//  Created by Alex da Franca on 14.06.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import SwiftUI

protocol BotListItem {
    var id: String { get }
    var title: String { get }
    var type: ListviewModelType { get }
    var destination: AnyView { get }
    var statusColor: Color { get }
    var searchableContent: String { get }
    var items: [BotListItem]? { get set }
}

enum ListviewModelType {
    case bot, integration
}
