//
//  CodeCoveragePreference.swift
//  XCSClient
//
//  Created by Alex da Franca on 21.06.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import Foundation

enum CodeCoveragePreference: Int, Codable {
    case none = 0
    case useSchemeSetting, enabled, disabled
}
