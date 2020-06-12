//
//  IntegrationsQueryResponse.swift
//  xcodeserverclient
//
//  Created by Alex da Franca on 05.06.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import Foundation

struct IntegrationsQueryResponse: Codable {
    let count: Int?
    let results: [Integration]
}
