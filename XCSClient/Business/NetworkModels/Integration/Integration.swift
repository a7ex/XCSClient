//
//  Integration.swift
//  xcodeserverclient
//
//  Created by Alex da Franca on 05.06.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import Foundation

struct Integration: Codable {
    let id: String // "824d4cdc2b61984cfc4e6556656d36c0",
    let rev: String? // "23-1505c13a74bcf06a4afb4b8c303f3c98",
    let assets: IntegrationAssets?
    let bot: Bot?
    let buildResultSummary: BuildResultSummary?
    let buildServiceFingerprint: String? // "35:A5:04:06:09:C6:8A:24:CE:58:F3:2C:30:BA:87:0C:FF:A2:E0:E0",
    let ccPercentage: Int? // 0,
    let ccPercentageDelta: Int? // 0,
    let currentStep: String? // "completed",
    let docType: String? // "integration",
    let duration: Double? // 491.034,
    
    let endedTime: Date? // "2020-05-28T07:59:23.098Z",
    
//    let endedTimeDate: String // [],
    let number: Int? // 94,
//    let perfMetricKeyPaths: String // [],
//    let perfMetricNames: String // [],
    let queuedDate: Date? // "2020-05-28T07:42:04.909Z",
    let result: IntegrationResult? // "warnings",
//    let revisionBlueprint: SourceControlBlueprint
    
    let startedTime: Date? // "2020-05-28T07:51:12.064Z",
    
//    let success_streak: String // 0,
//    let tags: String // [],
//    let testHierarchy: String // {},
    let testedDevices: [TestDevice]?
    let tinyID: String? // "3B5C700"
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case rev = "_rev"
        case docType = "doc_type"
        case assets
        case bot
        case buildResultSummary
        case buildServiceFingerprint
        case ccPercentage
        case ccPercentageDelta
        case currentStep
        case duration
        case endedTime
//        case endedTimeDate
        case number
//        case perfMetricKeyPaths
//        case perfMetricNames
        case queuedDate
        case result
//        case revisionBlueprint
        case startedTime
//        case success_streak, tags, testHierarchy
        case testedDevices
        case tinyID
    }
}

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
