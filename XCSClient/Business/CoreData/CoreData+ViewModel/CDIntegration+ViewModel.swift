//
//  CDIntegration+ViewModel.swift
//  XCSClient
//
//  Created by Alex da Franca on 31.12.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import SwiftUI

extension CDIntegration: IntegrationViewModel {
    
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
    
    
    var idString: String {
        return id ?? UUID().uuidString
    }
    
    var tinyIDString: String {
        return tinyID ?? "- missing -"
    }
    
    var botName: String {
        return bot?.name ?? "- missing -"
    }
    
    var botId: String {
        bot?.id ?? ""
    }
    
    var currentStepString: String {
        return currentStep ?? ""
    }
    
    var durationString: String {
        return Self.timeFormatter.string(from: duration) ?? ""
    }
    
    var listTitle: String {
        var title = "(\(number)) "
        if let date = queuedDate {
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
        guard let date = queuedDate else {
            return ""
        }
        return Self.dateFormatter.string(from: date)
    }
    
    var startTimes: String {
        var times = ""
        if let date = startedTime {
            times += Self.onlyTimeDateFormatter.string(from: date)
        }
        if let date = queuedDate {
            times += " (Queued: \(Self.onlyTimeDateFormatter.string(from: date)))"
        }
        return times
    }
    
    var endedTimeString: String {
        if let date = endedTime {
            return "Ended: \(Self.onlyTimeDateFormatter.string(from: date))"
        }
        return ""
    }
    
    var endedDateString: String {
        if let date = endedTime {
            return "\(Self.fullDateFormatter.string(from: date))"
        }
        return ""
    }
    
    var resultString: String {
        return (IntegrationResult(rawValue: result ?? "") ?? .unknown).rawValue
    }
    
    var statusColor: Color {
        switch integrationResult {
        case .analyzerWarnings, .warnings, .internalProcessingError:
            return Color(Colors.warning)
        case .buildErrors, .buildFailed, .checkoutError, .internalBuildError, .internalCheckoutError, .internalError, .triggerError:
            return Color(Colors.error)
        case .canceled:
            return Color(Colors.canceled)
        case .succeeded:
            return Color(Colors.success)
        case .testFailures:
            return Color(Colors.testFailures)
        case .unknown:
            return .clear
        }
    }
    
    var isInProgress: Bool {
        return currentStepString != "completed"
    }
    
    var sortedStatus: Int {
        guard !isInProgress else {
            return 0
        }
        switch integrationResult {
        case .analyzerWarnings, .warnings:
            return 2
        case .buildErrors, .buildFailed, .checkoutError, .internalBuildError, .internalCheckoutError, .internalError, .internalProcessingError, .triggerError:
            return 4
        case .canceled:
            return 5
        case .succeeded:
            return 1
        case .testFailures:
            return 3
        case .unknown:
            return 0
        }
    }
    
    var testedDevices: String {
        return Self.dateFormatter.string(from: startedTime ?? Date.distantPast)
    }
    
    var numberInt: Int {
        return Int(number)
    }
    
    var errorCount: Int {
        return Int(buildResultSummary?.errorCount ?? 0)
    }
    
    var errorChange: String {
        let change = buildResultSummary?.errorChange ?? 0
        return "\(change < 0 ? "": "+")\(change)"
    }
    
    var performsAnalyzeAction: Bool {
        return bot?.configuration?.performsAnalyzeAction ?? false
    }
    
    var analyzerWarnings: Int {
        return Int(buildResultSummary?.analyzerWarningCount ?? 0)
    }
    
    var analyzerWarningChange: String {
        let change = buildResultSummary?.analyzerWarningChange ?? 0
        return "\(change < 0 ? "": "+")\(change)"
    }
    
    var performsTestAction: Bool {
        return bot?.configuration?.performsTestAction ?? false
    }
    
    var codeCoverage: String {
        guard (ccPercentage + ccPercentageDelta) != 0 else {
            return ""
        }
        return "\(ccPercentage)% (delta: \(ccPercentageDelta))"
    }
    
    var performanceTests: String {
        guard ((buildResultSummary?.improvedPerfTestCount ?? 0) +
                (buildResultSummary?.regressedPerfTestCount ?? 0)) != 0 else {
            return ""
        }
        return "Improved: \(buildResultSummary?.improvedPerfTestCount ?? 0); Regressed: \(buildResultSummary?.regressedPerfTestCount ?? 0)"
    }
    
    var testFailureCount: Int {
        return Int(buildResultSummary?.testFailureCount ?? 0)
    }
    
    var testFailureChange: String {
        let change = buildResultSummary?.testFailureChange ?? 0
        return "\(change < 0 ? "": "+")\(change)"
    }
    
    var testsCount: Int {
        return Int(buildResultSummary?.testsCount ?? 0)
    }
    
    var testsCountChange: String {
        let change = buildResultSummary?.testsChange ?? 0
        return "\(change < 0 ? "+": "-")\(change)"
    }
    
    var passedTestsCount: Int {
        let all = Int(buildResultSummary?.testsCount ?? 0)
        let failed = Int(buildResultSummary?.testFailureCount ?? 0)
        return all - failed
    }
    
    var passedTestsChange: String {
        let change = buildResultSummary?.testFailureChange ?? 0
        return "\(change < 0 ? "+": "-")\(change)"
    }
    
    var warningCount: Int {
        return Int(buildResultSummary?.warningCount ?? 0)
    }
    
    var warningChange: String {
        let change = buildResultSummary?.warningChange ?? 0
        return "\(change < 0 ? "": "+")\(change)"
    }
    
    var archive: FileDescriptor {
        return FileDescriptor(logFile: assets?.archive?.asCodableObject)
    }
    
    var buildServiceLog: FileDescriptor {
        return FileDescriptor(logFile: assets?.buildServiceLog?.asCodableObject)
    }
    
    var sourceControlLog: FileDescriptor {
        return FileDescriptor(logFile: assets?.sourceControlLog?.asCodableObject)
    }
    
    var xcodebuildLog: FileDescriptor {
        return FileDescriptor(logFile: assets?.xcodebuildLog?.asCodableObject)
    }
    
    var xcodebuildOutput: FileDescriptor {
        return FileDescriptor(logFile: assets?.xcodebuildOutput?.asCodableObject)
    }
    
    var triggerAssets: [FileDescriptor] {
        guard let tAssets = assets?.triggerAssets,
              let triggerArray = Array(tAssets) as? [CDLogFile] else {
            return [FileDescriptor]()
        }
        return triggerArray.map { FileDescriptor(logFile: $0.asCodableObject) }.filter { $0.size > 0 }
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
        guard let primaryRemoteKey = revisionBlueprint?.primaryRemoteRepositoryKey,
              !primaryRemoteKey.isEmpty,
              let locationArray = Array(revisionBlueprint?.locations ?? NSSet()) as? [CDSingleSourceControlLocation],
              let srcLocation = locationArray.first(where: { $0.key == primaryRemoteKey }) else {
            return ""
        }
        return srcLocation.value?.locationRevisionKey ?? ""
    }
    
    var integrationResult: IntegrationResult {
        guard let result = result,
              let integrationResult = IntegrationResult(rawValue: result) else {
            return .unknown
        }
        return integrationResult
    }
    
    var sourceControlBranch: String {
        guard let firstLocation = revisionBlueprint?.locations?.anyObject() as? CDSingleSourceControlLocation,
              let scData = firstLocation.value else {
            return ""
        }
        return scData.branchIdentifierKey ?? ""
    }
    
    var revisionInformation: RevisionInfo {
        return RevisionInfo(
            author: revisionInfo?.author ?? "",
            date: revisionInfo?.date ?? "",
            comment: revisionInfo?.comment ?? ""
        )
    }
    
    private func updateRevisionInformation(with revInfo: RevisionInfo) {
        guard let context = managedObjectContext else {
            return
        }
        let cdRevInfo = CDRevisionInfo(context: context)
        cdRevInfo.update(with: revInfo)
        context.insert(cdRevInfo)
        revisionInfo = cdRevInfo
        do {
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func loadCommitData(completion: @escaping (RevisionInfo?) -> Void) {
        guard isServerReachable else {
            completion(nil)
            return
        }
        guard revisionInformation.isEmpty else {
            completion(revisionInformation)
            return
        }
        let assetPath = sourceControlLog.path
        guard !assetPath.isEmpty else {
            completion(nil)
            return
        }
        bot?.server?.connector.loadAsset(at: assetPath) { [weak self] (result) in
            switch result {
            case .success(let logData):
                guard let str = String(data: logData, encoding: .utf8) else {
                    completion(nil)
                    return
                }
                let substr = str.matches(regex: "log items:\\n\\s*Revision:.+?\\<Info\\>\\: Saving commit history")
                let revinf: RevisionInfo
                if let rev = substr.first {
                    let revString = String(rev.dropFirst(11))
                        .components(separatedBy: .newlines)
                        .dropLast()
                        .joined(separator: "\n")
                    let oneRevisionMatches = revString.matches(regex: "\\s*Revision:.+?\\n\\s*Revision:")
                    let oneRevision: String
                    if let frev = oneRevisionMatches.first {
                        oneRevision = String(frev.dropLast(10))
                    } else {
                        oneRevision = revString
                    }
                    revinf = RevisionInfo(snippet: oneRevision)
                } else {
                    revinf = RevisionInfo(author: "- No commit data -", date: "", comment: "")
                }
                self?.updateRevisionInformation(with: revinf)
                completion(revinf)
            case .failure:
                completion(nil)
            }
        }
    }
    
    var buildServiceSummaryItems: [BuildSummaryItem] {
        guard let cdItems = buildSummaryItems,
            let items = Array(cdItems) as? [CDBuildServiceSummaryItem] else {
            return [BuildSummaryItem]()
        }
        return items.map { $0.asCodableObject }
    }
    
    func loadBuildSummaryData(completion: @escaping ([BuildSummaryItem]) -> Void) {
        guard isServerReachable else {
            completion([BuildSummaryItem]())
            return
        }
        guard buildServiceSummaryItems.isEmpty else {
            completion(buildServiceSummaryItems)
            return
        }
        let assetPath = buildServiceLog.path
        guard !assetPath.isEmpty else {
            completion([BuildSummaryItem]())
            return
        }
        bot?.server?.connector.loadAsset(at: assetPath) { [weak self] (result) in
            switch result {
            case .success(let logData):
                guard let str = String(data: logData, encoding: .utf8) else {
                    completion([BuildSummaryItem]())
                    return
                }
                let items = BuildSummaryItem.itemsFromLog(str)
                if let context = self?.managedObjectContext {
                    let mapped = items.map { context.summaryItem(from: $0) }
                    self?.addToBuildSummaryItems(Set(mapped) as NSSet)
                    do {
                        try context.save()
                    } catch {
                        print(error.localizedDescription)
                    }
                }
                completion(items)
            case .failure:
                completion([BuildSummaryItem]())
            }
        }
    }
    
    private func updateBuildSummaryItems(with revInfo: RevisionInfo) {
        guard let context = managedObjectContext else {
            return
        }
        let cdRevInfo = CDRevisionInfo(context: context)
        cdRevInfo.update(with: revInfo)
        context.insert(cdRevInfo)
        revisionInfo = cdRevInfo
        do {
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private var isServerReachable: Bool {
        guard let server = bot?.server else {
            return false
        }
        return server.reachability == Int16(ServerReachabilty.reachable.rawValue)
    }
}

private extension String {
    func matches(regex: String) -> [String] {
        guard let regex = try? NSRegularExpression(pattern: regex, options: [.caseInsensitive, .dotMatchesLineSeparators]) else { return [] }
        let matches  = regex.matches(in: self, options: [], range: NSMakeRange(0, self.count))
        return matches.map { match in
            return String(self[Range(match.range, in: self)!])
        }
    }
}
