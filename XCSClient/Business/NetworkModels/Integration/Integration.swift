//
//  Integration.swift
//  xcodeserverclient
//
//  Created by Alex da Franca on 05.06.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import Foundation

struct Integration: Decodable {
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
    let revisionBlueprint: SourceControlBlueprint?
    let startedTime: Date? // "2020-05-28T07:51:12.064Z",
//    let success_streak: String // 0,
//    let tags: String // [],
    let testHierarchy: [String: JSONValue]?
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
        case revisionBlueprint
        case startedTime
//        case success_streak
//        case tags
        case testHierarchy
        case testedDevices
        case tinyID
    }
}

extension Integration {
    init(id: String, tinyId: String, bot: Bot) {
        self.id = id
        self.tinyID = tinyId
        self.bot = bot
        rev = nil
        docType = nil
        assets = nil
        buildResultSummary = nil
        buildServiceFingerprint = nil
        ccPercentage = nil
        ccPercentageDelta = nil
        currentStep = nil
        duration = nil
        endedTime = nil
        number = nil
        queuedDate = nil
        result = nil
        revisionBlueprint = nil
        startedTime = nil
        testHierarchy = nil
        testedDevices = nil
    }
}
