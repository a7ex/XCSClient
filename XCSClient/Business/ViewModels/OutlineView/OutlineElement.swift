//
//  OutlineElement.swift
//  XCSClient
//
//  Created by Alex da Franca on 26.12.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import SwiftUI

protocol OutlineElement {
    var id: String? { get }
    var children: [OutlineElement]? { get }
    var title: String { get }
    var statusColor: Color { get } 
    var destination: AnyView { get }
    var systemIconName: String { get }
    var isInProgress: Bool { get }
}
