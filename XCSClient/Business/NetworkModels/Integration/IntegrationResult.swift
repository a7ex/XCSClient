//
//  IntegrationResult.swift
//  XCSClient
//
//  Created by Alex da Franca on 21.06.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import Foundation

enum IntegrationResult: String, Codable {
    case succeeded
    case warnings
    case canceled
    case unknown
    case testFailures = "test-failures"
    case buildErrors = "build-errors"
    case analyzerWarnings = "analyzer-warnings"
    case buildFailed = "build-failed"
    case checkoutError = "checkout-error"
    case internalError = "internal-error"
    case triggerError = "trigger-error"
    case internalCheckoutError = "internal-checkout-error"
    case internalBuildError = "internal-build-error"
    case internalProcessingError = "internal-processing-error"
}
