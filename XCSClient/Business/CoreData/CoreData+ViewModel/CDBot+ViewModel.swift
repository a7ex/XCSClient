//
//  CDBot+ViewModel.swift
//  XCSClient
//
//  Created by Alex da Franca on 31.12.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import Foundation

extension CDBot: BotViewModel {
    var idString: String {
        return id ?? UUID().uuidString
    }
    
    var revIdString: String {
        return rev ?? UUID().uuidString
    }
    
    var tinyIDString: String {
        return tinyID ?? ""
    }
    
    var nameString: String {
        return name ?? "<Untitled>"
    }
    
    var integrationCounterInt: Int {
        return Int(integrationCounter)
    }
    
    var performsAnalyzeAction: Bool {
        return configuration?.performsAnalyzeAction ?? false
    }
    
    var performsTestAction: Bool {
        return configuration?.performsTestAction ?? false
    }
    
    var performsArchiveAction: Bool {
        return configuration?.performsArchiveAction ?? false
    }
    
    var performsUpgradeIntegration: Bool {
        return configuration?.performsUpgradeIntegration ?? false
    }
    
    var additionalBuildArguments: String {
        return configuration?.additionalBuildArguments?.joined(separator: ",") ?? ""
    }
    
    var buildEnvironmentVariables: [String : String] {
        return configuration?.buildEnvironmentVariables ?? [String: String]()
    }
    
    var archiveExportOptionsName: String {
        return configuration?.archiveExportOptions?.name ?? ""
    }
    
    var archiveExportOptionsProvisioningProfiles: String {
        let profiles = configuration?.archiveExportOptions?.exportOptions?.provisioningProfiles
        let allProfiles = profiles?.values
        return allProfiles?.joined(separator: ", ") ?? ""
    }
    
    var disableAppThinning: Bool {
        return configuration?.disableAppThinning ?? false
    }
    
    var exportsProductFromArchive: Bool {
        return configuration?.exportsProductFromArchive ?? false
    }
    
    var integrationTimeSchedule: String {
        return "\(configuration?.hourOfIntegration ?? 0)"
    }
    
    var integrationMinuteSchedule: String {
        return "\(configuration?.minutesAfterHourToIntegrate ?? 0)"
    }
    
    var weeklyScheduleDay: String {
        return configuration?.weeklyScheduleDay.string ?? ""
    }
    
    var periodicScheduleIntervalString: String {
        return periodicScheduleInterval.string
    }
    
    var periodicScheduleInterval: PeriodicScheduleInterval {
        return PeriodicScheduleInterval.none
    }
    
    var scheduleTypeAsString: String {
        return scheduleType.string
    }
    
    var scheduleType: ScheduleType {
        return configuration?.scheduleType ?? ScheduleType.none
    }
    
    var schemeName: String {
        return configuration?.schemeName ?? ""
    }
    
    var buildConfiguration: String {
        return configuration?.buildConfiguration ?? ""
    }
    
    var sourceControlBranch: String {
        guard let locations = Array(configuration?.sourceControlBlueprint?.locations ?? NSSet()) as? [CDSingleSourceControlLocation],
              let primaryRepo = configuration?.sourceControlBlueprint?.primaryRemoteRepositoryKey,
              let location = locations.first(where: { $0.key == primaryRepo }) else {
            return ""
        }
        return location.value?.branchIdentifierKey ?? ""
    }
    
    var triggerScripts: [TriggerScript] {
        let triggers = Array(configuration?.triggers ?? NSSet()) as? [CDTrigger]
        return triggers?.compactMap({ $0.asTriggerScript }) ?? [TriggerScript]()
    }
    
    var archiveExportOptions: ArchiveExportOptions {
        return configuration?.archiveExportOptions?.asCodableObject ??
            ArchiveExportOptions(name: "", createdAt: Date.distantPast, exportOptions: nil)
    }
    
    var exportSettings: String {
        var duplicate = asCodableObject
        duplicate.requiresUpgrade = false
        duplicate.duplicatedFrom = id ?? ""
        duplicate.id = nil
        duplicate.rev = nil
        duplicate.tinyID = nil
        duplicate.docType = nil
        duplicate.integrationCounter = nil
        duplicate.lastRevisionBlueprint = nil
        duplicate.sourceControlBlueprintIdentifier = nil
        duplicate.configuration?.sourceControlBlueprint?.identifierKey = UUID().uuidString
        return duplicate.asBodyParamater
    }
    
    func applying(_ botEditableData: BotEditorData) -> RequestBodyParameterProvider {
        return asCodableObject.applying(botEditableData)
    }
    
    var integrationInProgress: Bool {
        guard let integrations = children?.filter({ $0 is CDIntegration }) as? [CDIntegration],
              let firstIntegration = integrations.first(
                where: { $0.integrationResult != .canceled }
              ) else {
            return false
        }
        return firstIntegration.currentStepString != "completed"
    }
}
