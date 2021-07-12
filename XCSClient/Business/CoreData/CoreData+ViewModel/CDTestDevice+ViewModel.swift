//
//  CDTestDevice+ViewModel.swift
//  XCSClient
//
//  Created by Alex da Franca on 12.07.21.
//  Copyright © 2021 Farbflash. All rights reserved.
//

import Foundation

extension CDTestDevice {
    var listTitle: String {
        return name ?? id ?? "- no Id -"
    }
    var listID: String {
        return id ?? UUID().uuidString
    }
}
