//
//  ExpandableBotList.swift
//  XCSClient
//
//  Created by Alex da Franca on 14.06.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import SwiftUI

protocol ExpandableBotListItem {
    var id: String { get }
    var title: String { get }
    var type: ListviewModelType { get }
    var isExpandable: Bool { get }
    var isExpanded: Bool { get set }
    var destination: AnyView { get }
    var statusColor: Color { get }
    var searchableContent: String { get }
}

enum ListviewModelType {
    case bot, integration
}
