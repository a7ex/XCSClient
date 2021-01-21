//
//  BotViewModel.swift
//  XCSClient
//
//  Created by Alex da Franca on 31.12.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import Foundation

protocol BotViewModel {
    var idString: String { get }
    var revIdString: String { get }
    var tinyIDString: String { get }
    var nameString: String { get }
    var integrationCounterInt: Int { get }
    var performsAnalyzeAction: Bool { get }
    var performsTestAction: Bool { get }
    var performsArchiveAction: Bool { get }
    var performsUpgradeIntegration: Bool { get }
    var additionalBuildArguments: String { get }
    var buildEnvironmentVariables: [String: String] { get }
    var archiveExportOptionsName: String { get }
    var archiveExportOptionsProvisioningProfiles: String { get }
    var disableAppThinning: Bool { get }
    var exportsProductFromArchive: Bool { get }
    var integrationTimeSchedule: String { get }
    var integrationMinuteSchedule: String { get }
    var weeklyScheduleDay: String { get }
    var periodicScheduleIntervalString: String { get }
    var periodicScheduleInterval: PeriodicScheduleInterval { get }
    var scheduleTypeAsString: String { get }
    var scheduleType: ScheduleType { get }
    var schemeName: String { get }
    var buildConfiguration: String { get }
    var sourceControlBranch: String { get }
    var triggerScripts: [TriggerScript] { get }
    var archiveExportOptions: ArchiveExportOptions { get }
    var exportSettings: String { get }
    func applying(_ botEditableData: BotEditorData) -> RequestBodyParameterProvider
    var firstIntegration: IntegrationViewModel? { get }
    
    func loadCommitData(completion: @escaping (RevisionInfo) -> Void)
    func addIntegration(_ integration: Integration)
    func deleteBot()
    func duplicate(bot: Bot)
    func updateBot(with bot: Bot)
    
    func updateIntegrationsFromBackend()
}

protocol RequestBodyParameterProvider {
    var asBodyParamater: String { get }
}
