//
//  TestDeviceFilter.swift
//  xcodeserverclient
//
//  Created by Alex da Franca on 04.06.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import Foundation

struct TestDeviceFilter: Codable {
    var architectureType: Int?
    var filterType: Int?
    var platform: Platform?
}
