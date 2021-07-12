//
//  IntegrationViewModel.swift
//  XCSClient
//
//  Created by Alex da Franca on 31.12.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import SwiftUI

protocol IntegrationViewModel {
    var idString: String { get }
    var tinyIDString: String { get }
    var botName: String { get }
    var botId: String { get }
    var currentStepString: String { get }
    var durationString: String { get }
    var listTitle: String { get }
    var startDate: String { get }
    var startTimes: String { get }
    var startedTime: Date? { get }
    var endedTimeString: String { get }
    var endedDateString: String { get }
    var resultString: String { get }
    var statusColor: Color { get }
    var testedDevices: String { get }
    var numberInt: Int { get }
    var errorCount: Int { get }
    var errorChange: String { get }
    var performsAnalyzeAction: Bool { get }
    var analyzerWarnings: Int { get }
    var analyzerWarningChange: String { get }
    var performsTestAction: Bool { get }
    var codeCoverage: String { get }
    var performanceTests: String { get }
    var testFailureCount: Int { get }
    var testFailureChange: String { get }
    var testsCount: Int { get }
    var testsCountChange: String { get }
    var passedTestsCount: Int { get }
    var passedTestsChange: String { get }
    var warningCount: Int { get }
    var warningChange: String { get }
    var archive: FileDescriptor { get }
    var buildServiceLog: FileDescriptor { get }
    var sourceControlLog: FileDescriptor { get }
    var xcodebuildLog: FileDescriptor { get }
    var xcodebuildOutput: FileDescriptor { get }
    var triggerAssets: [FileDescriptor] { get }
    var hasAssets: Bool { get }
    var sourceControlCommitId: String { get }
    var sourceControlBranch: String { get }
    var revisionInformation: RevisionInfo { get }
    var isInProgress: Bool { get }
    var buildServiceSummaryItems: [BuildSummaryItem] { get }
    func loadCommitData(completion: @escaping (RevisionInfo?) -> Void)
    func loadBuildSummaryData(completion: @escaping ([BuildSummaryItem]) -> Void)
}
