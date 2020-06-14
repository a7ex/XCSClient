//
//  IntegrationVM.swift
//  XCSClient
//
//  Created by Alex da Franca on 14.06.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import Foundation

struct IntegrationVM {
    private static let timeFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        //        style: .positional  // 2:46:40
        //        style: .abbreviated // 2h 46m 40s
        //        style: .short       // 2 hr, 46 min, 40 sec
        //        style: .full        // 2 hours, 46 minutes, 40 seconds
        //        style: .spellOut    // two hours, forty-six minutes, forty seconds
        //        style: .brief       // 2hr 46min 40sec
        return formatter
    }()
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
    private static let onlyTimeDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()
    
    let integrationModel: Integration
    
    var id: String {
        return integrationModel.id
    }
    var tinyID: String {
        return integrationModel.tinyID ?? "- missing -"
    }
    var botName: String {
        return integrationModel.bot?.name ?? "- missing -"
    }
    var currentStep: String {
        return integrationModel.currentStep ?? ""
    }
    var duration: String {
        return Self.timeFormatter.string(from: integrationModel.duration ?? 0) ?? ""
    }
    var queuedDate: String {
        return Self.dateFormatter.string(from: integrationModel.queuedDate ?? Date.distantPast)
    }
    var startedTime: String {
        return Self.onlyTimeDateFormatter.string(from: integrationModel.startedTime ?? Date.distantPast)
    }
    var endedTime: String {
        return Self.onlyTimeDateFormatter.string(from: integrationModel.endedTime ?? Date.distantFuture)
    }
    var result: String {
        return (integrationModel.result ?? IntegrationResult.unknown).rawValue
    }
    var testedDevices: String {
        return Self.dateFormatter.string(from: integrationModel.startedTime ?? Date.distantPast)
    }
    var number: String {
        return "\(integrationModel.number ?? 0)"
    }
    var analyzerWarnings: String {
        return "\(integrationModel.buildResultSummary?.analyzerWarningCount ?? 0) (\(integrationModel.buildResultSummary?.analyzerWarningChange ?? 0))"
    }
    var codeCoverage: String {
        return "\(integrationModel.ccPercentage ?? 0)% (delta: \(integrationModel.ccPercentageDelta ?? 0))"
    }
    var errorCount: String {
        return "\(integrationModel.buildResultSummary?.errorCount ?? 0) (\(integrationModel.buildResultSummary?.errorChange ?? 0))"
    }
    var performanceTests: String {
        return "Improved: \(integrationModel.buildResultSummary?.improvedPerfTestCount ?? 0); Regressed: \(integrationModel.buildResultSummary?.regressedPerfTestCount ?? 0)"
    }
    var testFailureCount: String {
        return "\(integrationModel.buildResultSummary?.testFailureCount ?? 0) (\(integrationModel.buildResultSummary?.testFailureChange ?? 0))"
    }
    var testsCount: String {
        return "\(integrationModel.buildResultSummary?.testsCount ?? 0) (\(integrationModel.buildResultSummary?.testsChange ?? 0))"
    }
    var warningCount: String {
        return "\(integrationModel.buildResultSummary?.warningCount ?? 0) (\(integrationModel.buildResultSummary?.warningChange ?? 0))"
    }
    
    
    init(integration: Integration) {
        integrationModel = integration
    }
}
