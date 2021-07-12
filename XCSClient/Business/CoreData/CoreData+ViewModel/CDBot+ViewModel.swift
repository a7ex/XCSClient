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
        return PeriodicScheduleInterval(rawValue: Int(configuration?.periodicScheduleIntervalValue ?? 0)) ?? PeriodicScheduleInterval.none
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
    
    var testDevices: [String: String] {
        guard let deviceIdentifiers = configuration?.deviceSpecification?.deviceIdentifiers else {
            return [String: String]()
        }
        return deviceIdentifiers.reduce([String: String]()) { devicesList, identifier in
            var devicesList = devicesList
            devicesList[identifier] = managedObjectContext?.deviceName(for: identifier) ?? identifier
            return devicesList
        }
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
        guard let integration = firstCDIntegration else {
            return false
        }
        return integration.currentStepString != "completed"
    }
    
    var firstIntegration: IntegrationViewModel? {
        return firstCDIntegration
    }
    
    var firstCDIntegration: CDIntegration? {
        guard let integrations = children?.filter({ $0 is CDIntegration }) as? [CDIntegration],
              let firstIntegration = integrations.first(
                where: { $0.integrationResult != .canceled }
              ) else {
            return nil
        }
        return firstIntegration
    }
    
    func loadCommitData(completion: @escaping (RevisionInfo) -> Void) {
        firstIntegration?.loadCommitData() { revInfo in
            guard let revInfo = revInfo else {
                return
            }
            completion(revInfo)
        }
    }
    
    func addIntegration(_ integration: Integration) {
        if let cdIntegration = managedObjectContext?.integration(from: integration) {
            addToItems(cdIntegration)
            saveContext()
        }
    }
    
    func deleteBot() {
        if let server = server {
            server.removeFromItems(self)
            saveContext()
        }
    }
    
    func duplicate(bot: Bot) {
        if let context = managedObjectContext,
           let newBot = context.bot(from: bot) {
            server?.addToItems(newBot)
            saveContext()
        }
    }
    
    func updateBot(with bot: Bot) {
        update(with: bot)
        saveContext()
    }
    
    private func saveContext() {
        guard let moc = managedObjectContext else {
            return
        }
        do {
            try moc.save()
        } catch {
            print("Save context error: \(error.localizedDescription)")
        }
    }
}
