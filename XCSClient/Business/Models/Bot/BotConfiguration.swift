//
//  BotConfiguration.swift
//  xcodeserverclient
//
//  Created by Alex da Franca on 04.06.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import Foundation

struct BotConfiguration: Codable {
    var additionalBuildArguments: [String]?
//    var buildEnvironmentVariables: [String: Any]
    var deviceSpecification: TestDeviceSpecification?
    var builtFromClean: Int?
    var codeCoveragePreference: CodeCoveragePreference? // only if 'performsTestAction' set to true
    var disableAppThinning: Bool?
    var exportsProductFromArchive: Bool?
    var hourOfIntegration: Int? // only if 'periodicScheduleInterval' set to 2 (Daily) or 3 (Weekly)
    var minutesAfterHourToIntegrate: Int? // only if 'periodicScheduleInterval' set to 1 (Hourly)
    var performsAnalyzeAction: Bool?
    var performsArchiveAction: Bool?
    var performsTestAction: Bool?
    var performsUpgradeIntegration: Bool?
    var periodicScheduleInterval: PeriodicScheduleInterval? // only relevant, if scheduleType == periodically (1)
    var provisioningConfiguration: ProvisioningConfiguration?
    var runOnlyDisabledTests: Bool?
    var scheduleType: ScheduleType?
    var schemeName: String?
    var sourceControlBlueprint: SourceControlBlueprint?
//    var testLocalizations: [Any]
    var testingDestinationType: Int?
    var triggers: [Trigger]?
    var useParallelDeviceTesting: Bool?
    var weeklyScheduleDay: WeeklyScheduleDay? // only if 'periodicScheduleInterval' set to 3 (Weekly)
    var buildConfiguration: String?
}

enum ScheduleType: Int, Codable {
    case none = 0
    case periodically, onCommit, manually
}
enum PeriodicScheduleInterval: Int, Codable {
    case none = 0
    case hourly, daily, weekly
}
enum WeeklyScheduleDay: Int, Codable {
    case none = 0
    case monday, tuesday, wednesday, thursday, friday, saturday, sunday
}
enum BuiltFromClean: Int, Codable {
    case never = 0
    case always, onceADay, onceAWeek
}
enum CodeCoveragePreference: Int, Codable {
    case none = 0
    case useSchemeSetting, enabled, disabled
}
