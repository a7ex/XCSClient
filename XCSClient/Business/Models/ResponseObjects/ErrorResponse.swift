//
//  ErrorResponse.swift
//  xcodeserverclient
//
//  Created by Alex da Franca on 08.06.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import Foundation

struct ErrorResponse: Codable {
    let message: String
    let status: Int
}
