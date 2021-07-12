//
//  VariablePair.swift
//  XCSClient
//
//  Created by Alex da Franca on 21.08.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import Foundation

struct VariablePair: Identifiable, Equatable {
    var id: String
    var value: String
    
    var isEmpty: Bool {
        return id.isEmpty && value.isEmpty
    }
}
