//
//  IntegrationVM.swift
//  XCSClient
//
//  Created by Alex da Franca on 14.06.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import SwiftUI

struct IntegrationVM: IntegrationViewModel {
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
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    private static let onlyTimeDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()
    
    private static let fullDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
    let integrationModel: Integration
    
    var idString: String {
        return integrationModel.id
    }
    var tinyIDString: String {
        return integrationModel.tinyID ?? "- missing -"
    }
    var botName: String {
        return integrationModel.bot?.name ?? "- missing -"
    }
    var botId: String {
        return integrationModel.bot?.id ?? ""
    }
//    var botVM: BotViewModel? {
//        guard let bot = integrationModel.bot else {
//            return nil
//        }
//        return BotVM(bot: bot)
//    }
    var currentStepString: String {
        return integrationModel.currentStep ?? ""
    }
    var durationString: String {
        return Self.timeFormatter.string(from: integrationModel.duration ?? 0) ?? ""
    }
    var listTitle: String {
        if tinyIDString == "Loading integrations…" {
            return "Loading integrations…"
        }
        var title = "(\(numberInt)) "
        if let date = integrationModel.queuedDate {
            title += "\(Self.fullDateFormatter.string(from: date))\t"
        }
        if resultString == "unknown" {
            title += currentStepString
        } else {
            title += resultString
        }
        return title
    }
    var startDate: String {
        guard let date = integrationModel.queuedDate else {
            return ""
        }
        return Self.dateFormatter.string(from: date)
    }
    var startTimes: String {
        var times = ""
        if let date = integrationModel.startedTime {
            times += Self.onlyTimeDateFormatter.string(from: date)
        }
        if let date = integrationModel.queuedDate {
            times += " (Queued: \(Self.onlyTimeDateFormatter.string(from: date)))"
        }
        return times
    }
    
    var startedTime: Date? {
        return integrationModel.startedTime
    }
    
    var endedTimeString: String {
        if let date = integrationModel.endedTime {
            return "Ended: \(Self.onlyTimeDateFormatter.string(from: date))"
        }
        return ""
    }
    var resultString: String {
        return (integrationModel.result ?? IntegrationResult.unknown).rawValue
    }
    var statusColor: Color {
        guard let result = integrationModel.result else {
            return .clear
        }
        switch result {
        case .analyzerWarnings, .warnings:
            return .orange
        case .buildErrors, .buildFailed, .checkoutError, .internalBuildError, .internalCheckoutError, .internalError, .internalProcessingError, .triggerError:
            return .red
        case .canceled:
            return .gray
        case .succeeded:
            return .green
        case .testFailures:
            return .purple
        case .unknown:
            return .clear
        }
    }
    var testedDevices: String {
        return Self.dateFormatter.string(from: integrationModel.startedTime ?? Date.distantPast)
    }
    var numberInt: Int {
        return integrationModel.number ?? 0
    }
    var errorCount: Int {
        return integrationModel.buildResultSummary?.errorCount ?? 0
    }
    var errorChange: String {
        let change = integrationModel.buildResultSummary?.errorChange ?? 0
        return "\(change < 0 ? "": "+")\(change)"
    }
    
    var performsAnalyzeAction: Bool {
        return integrationModel.bot?.configuration?.performsAnalyzeAction ?? false
    }
    var analyzerWarnings: Int {
        return integrationModel.buildResultSummary?.analyzerWarningCount ?? 0
    }
    var analyzerWarningChange: String {
        let change = integrationModel.buildResultSummary?.analyzerWarningChange ?? 0
        return "\(change < 0 ? "": "+")\(change)"
    }
    
    var performsTestAction: Bool {
        return integrationModel.bot?.configuration?.performsTestAction ?? false
    }
    var codeCoverage: String {
        return "\(integrationModel.ccPercentage ?? 0)% (delta: \(integrationModel.ccPercentageDelta ?? 0))"
    }
    var performanceTests: String {
        return "Improved: \(integrationModel.buildResultSummary?.improvedPerfTestCount ?? 0); Regressed: \(integrationModel.buildResultSummary?.regressedPerfTestCount ?? 0)"
    }
    var testFailureCount: Int {
        return integrationModel.buildResultSummary?.testFailureCount ?? 0
    }
    var testFailureChange: String {
        let change = integrationModel.buildResultSummary?.testFailureChange ?? 0
        return "\(change < 0 ? "": "+")\(change)"
    }
    var testsCount: Int {
        return integrationModel.buildResultSummary?.testsCount ?? 0
    }
    var testsCountChange: String {
        let change = integrationModel.buildResultSummary?.testsChange ?? 0
        return "\(change < 0 ? "+": "-")\(change)"
    }
    var passedTestsCount: Int {
        let all = integrationModel.buildResultSummary?.testsCount ?? 0
        let failed = integrationModel.buildResultSummary?.testFailureCount ?? 0
        return all - failed
    }
    var passedTestsChange: String {
        let change = integrationModel.buildResultSummary?.testFailureChange ?? 0
        return "\(change < 0 ? "+": "-")\(change)"
    }
    var warningCount: Int {
        return integrationModel.buildResultSummary?.warningCount ?? 0
    }
    var warningChange: String {
        let change = integrationModel.buildResultSummary?.warningChange ?? 0
        return "\(change < 0 ? "": "+")\(change)"
    }
    var archive: FileDescriptor {
        return FileDescriptor(logFile: integrationModel.assets?.archive)
    }
    var buildServiceLog: FileDescriptor {
        return FileDescriptor(logFile: integrationModel.assets?.buildServiceLog)
    }
    var sourceControlLog: FileDescriptor {
        return FileDescriptor(logFile: integrationModel.assets?.sourceControlLog)
    }
    var xcodebuildLog: FileDescriptor {
        return FileDescriptor(logFile: integrationModel.assets?.xcodebuildLog)
    }
    var xcodebuildOutput: FileDescriptor {
        return FileDescriptor(logFile: integrationModel.assets?.xcodebuildOutput)
    }
    var triggerAssets: [FileDescriptor] {
        return integrationModel.assets?.triggerAssets?.map { FileDescriptor(logFile: $0) }.filter { $0.size > 0 } ?? [FileDescriptor]()
    }
    var hasAssets: Bool {
        return archive.size +
            buildServiceLog.size +
            sourceControlLog.size +
            xcodebuildLog.size +
            xcodebuildOutput.size +
            triggerAssets.count > 0
    }
    var sourceControlCommitId: String {
        guard let primaryRemoteKey = integrationModel.revisionBlueprint?.primaryRemoteRepositoryKey,
            !primaryRemoteKey.isEmpty,
       let srcLocation = integrationModel.revisionBlueprint?.locationsKey?[primaryRemoteKey] else {
                return ""
        }
        return srcLocation.locationRevisionKey ?? ""
    }
    
    init(integration: Integration) {
        integrationModel = integration
    }
}
