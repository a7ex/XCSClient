//
//  OptionalExtension.swift
//  DHLPaket
//
//  Created by Alex da Franca on 09.08.20.
//  Copyright © 2020 Deutsche Post IT Services Berlin GmbH. All rights reserved.
//

import Foundation

extension Optional where Wrapped: StringProtocol {
    var isNotEmpty: Bool {
        guard case let .some(value) = self as? String else {
            return false
        }
        return !value.isEmpty
    }
    var notEmptyString: String? {
        guard case let .some(value) = self as? String,
            !value.isEmpty else {
            return nil
        }
        return value
    }
}
