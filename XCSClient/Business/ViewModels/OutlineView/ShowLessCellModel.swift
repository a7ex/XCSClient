//
//  ShowLessCellModel.swift
//  XCSClient
//
//  Created by Alex da Franca on 02.01.21.
//  Copyright © 2021 Farbflash. All rights reserved.
//

import SwiftUI

struct ShowLessCellModel: OutlineElement {
    var id: String? = UUID().uuidString
    var children: [OutlineElement]? = nil
    var title = "ShowMoreOrLessCell"
    var statusColor = Color.clear
    var destination: AnyView = AnyView(Text("Dummy"))
    let systemIconName = ""
    let isInProgress = false
    let bot: CDBot
}
