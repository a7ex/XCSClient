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
    var buildEnvironmentVariables: [String: String]?
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
    var testLocalizations: [String]?
    var testingDestinationType: Int?
    var triggers: [Trigger]?
    var useParallelDeviceTesting: Bool?
    var weeklyScheduleDay: WeeklyScheduleDay? // only if 'periodicScheduleInterval' set to 3 (Weekly)
    var buildConfiguration: String?
    var archiveExportOptions: ArchiveExportOptions?
    
    static func standard(scheme: String, sourceControlBlueprint: SourceControlBlueprint) -> BotConfiguration {
        return BotConfiguration(
            additionalBuildArguments: nil,
            buildEnvironmentVariables: nil,
            deviceSpecification: nil,
            builtFromClean: nil,
            codeCoveragePreference: nil,
            disableAppThinning: nil,
            exportsProductFromArchive: nil,
            hourOfIntegration: nil,
            minutesAfterHourToIntegrate: nil,
            performsAnalyzeAction: nil,
            performsArchiveAction: nil,
            performsTestAction: nil,
            performsUpgradeIntegration: nil,
            periodicScheduleInterval: nil,
            provisioningConfiguration: nil,
            runOnlyDisabledTests: nil,
            scheduleType: nil,
            schemeName: scheme,
            sourceControlBlueprint: sourceControlBlueprint,
            testLocalizations: nil,
            testingDestinationType: nil,
            triggers: [Trigger](),
            useParallelDeviceTesting: nil,
            weeklyScheduleDay: nil,
            buildConfiguration: nil,
            archiveExportOptions: nil
        )
    }
}
