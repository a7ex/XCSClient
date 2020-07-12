//
//  Integration.swift
//  xcodeserverclient
//
//  Created by Alex da Franca on 05.06.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import Foundation

struct Integration: Decodable {
    let id: String
    let rev: String?
    let assets: IntegrationAssets?
    let bot: Bot?
    let buildResultSummary: BuildResultSummary?
    let buildServiceFingerprint: String?
    let ccPercentage: Int?
    let ccPercentageDelta: Int?
    let currentStep: String? // "completed",
    let docType: String? // "integration",
    let duration: Double?
    let endedTime: Date? // "2020-05-28T07:59:23.098Z",
//    let endedTimeDate: String // [],
    let number: Int?
//    let perfMetricKeyPaths: String // [],
//    let perfMetricNames: String // [],
    let queuedDate: Date? // "2020-05-28T07:42:04.909Z",
    let result: IntegrationResult? // "warnings",
    let revisionBlueprint: SourceControlBlueprint?
    let startedTime: Date? // "2020-05-28T07:51:12.064Z",
//    let success_streak: String
//    let tags: String // [],
    let testHierarchy: [String: JSONValue]?
    let testedDevices: [TestDevice]?
    let tinyID: String?
    
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
