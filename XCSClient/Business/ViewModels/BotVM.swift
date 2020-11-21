//
//  BotVM.swift
//  XCSClient
//
//  Created by Alex da Franca on 14.06.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import Foundation

struct BotVM {
    let botModel: Bot
    
    var id: String {
        return botModel.id ?? UUID().uuidString
    }
    var tinyID: String {
        return botModel.tinyID ?? "- missing -"
    }
    var name: String {
        return botModel.name
    }
    var integrationCounter: Int {
        return botModel.integrationCounter ?? 0
    }
    var performsAnalyzeAction: Bool {
        return botModel.configuration?.performsAnalyzeAction ?? false
    }
    var performsTestAction: Bool {
        return botModel.configuration?.performsTestAction ?? false
    }
    var performsArchiveAction: Bool {
        return botModel.configuration?.performsArchiveAction ?? false
    }
    var performsUpgradeIntegration: Bool {
        return botModel.configuration?.performsUpgradeIntegration ?? false
    }
    var additionalBuildArguments: String {
        return botModel.configuration?.additionalBuildArguments?.joined(separator: ", ") ?? ""
    }
    var buildEnvironmentVariables: [String: String] {
        guard let envVars = botModel.configuration?.buildEnvironmentVariables else {
            return [String: String]()
        }
        return envVars
    }
    var archiveExportOptionsName: String {
        return botModel.configuration?.archiveExportOptions?.name ?? ""
    }
    var archiveExportOptionsProvisioningProfiles: String {
        let profiles = botModel.configuration?.archiveExportOptions?.exportOptions?.provisioningProfiles
        let allProfiles = profiles?.values
        return allProfiles?.joined(separator: ", ") ?? ""
    }
    var disableAppThinning: Bool {
        return botModel.configuration?.disableAppThinning ?? false
    }
    var exportsProductFromArchive: Bool {
        return botModel.configuration?.exportsProductFromArchive ?? false
    }
    var integrationTimeSchedule: String {
        return "\(botModel.configuration?.hourOfIntegration ?? 0)"
    }
    var integrationMinuteSchedule: String {
        return "\(botModel.configuration?.minutesAfterHourToIntegrate ?? 0)"
    }
    var weeklyScheduleDay: String {
        return botModel.configuration?.weeklyScheduleDay?.string ?? ""
    }
    var periodicScheduleInterval: String {
        return botModel.configuration?.periodicScheduleInterval?.string ?? ""
    }
    var scheduleType: String {
        return botModel.configuration?.scheduleType?.string ?? ""
    }
    var schemeName: String {
        return botModel.configuration?.schemeName ?? ""
    }
    var buildConfiguration: String {
        return botModel.configuration?.buildConfiguration ?? ""
    }
    var sourceControlBranch: String {
        guard let locations = botModel.configuration?.sourceControlBlueprint?.locationsKey,
            let pimaryRepo = botModel.configuration?.sourceControlBlueprint?.primaryRemoteRepositoryKey,
            let location = locations[pimaryRepo] else {
                return ""
        }
        return location.branchIdentifierKey ?? ""
    }
    var triggerScripts: [TriggerScript] {
        guard let triggers = botModel.configuration?.triggers else {
            return [TriggerScript]()
        }
        return triggers.compactMap { TriggerScript(name: $0.name, script: $0.scriptBody) }
    }
    
    init(bot: Bot) {
        botModel = bot
    }
}

extension ScheduleType {
    var string: String {
        switch self {
        case .periodically:
            return "Periodically"
        case .onCommit:
            return "On Commit"
        case .manually:
            return "Manually"
        case .none:
            return ""
        }
    }
    static var allStringValues: [String] {
        return ScheduleType.allCases
            .map { $0.string }
            .filter { !$0.isEmpty }
    }
}

extension WeeklyScheduleDay {
    var string: String {
        switch self {
        case .monday:
            return "Monday"
        case .tuesday:
            return "Tuesday"
        case .wednesday:
            return "Wednesday"
        case .thursday:
            return "Thursday"
        case .friday:
            return "Friday"
        case .saturday:
            return "Saturday"
        case .sunday:
            return "Sunday"
        case .none:
            return ""
        }
    }
}

extension PeriodicScheduleInterval {
    var string: String {
        switch self {
        case .daily:
            return "Daily"
        case .hourly:
            return "Hourly"
        case .weekly:
            return "Weekly"
        case .none:
            return ""
        }
    }
}
