//
//  BotEditorData.swift
//  XCSClient
//
//  Created by Alex da Franca on 12.07.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import SwiftUI

class BotEditorData: ObservableObject, Equatable {
    @Published var branch = ""
    @Published var scheme = ""
    @Published var buildConfig = ""
    @Published var additionalBuildArguments = ""
    @Published var name = ""
    @Published var performsAnalyzeAction = false
    @Published var performsTestAction = false
    @Published var performsArchiveAction = false
    @Published var performsUpgradeIntegration = false
    @Published var disableAppThinning = false
    @Published var exportsProductFromArchive = false
    @Published var scheduleType = ""
    @Published var triggerScripts = [TriggerScript]()
    @Published var environmentVariables = [VariablePair]()
    @Published var exportOptions = ArchiveExportOptions(name: "", createdAt: Date.distantPast, exportOptions: nil)
    @Published var testDevices = [String: String]()
    
    private var snapShot: BotEditorData?
    
    var hasChanges: Bool {
        return self != snapShot
    }
    
    func updateExportOptions(with data: Data, at url: URL) {
        let decoder = PropertyListDecoder()
        if let exportOpts = try? decoder.decode(IPAExportOptions.self, from: data) {
            let expOptions = ArchiveExportOptions(name: url.lastPathComponent, createdAt: Date(), exportOptions: exportOpts)
            exportOptions = expOptions
        }
    }
    
    func updateTriggerScript(with name: String, scriptText: String) {
        guard let newTriggerScript = TriggerScript(
                name: name,
                script: scriptText
        ) else {
            return
        }
        triggerScripts = triggerScripts.map { script in
            if script.name == newTriggerScript.name {
                return newTriggerScript
            } else {
                return script
            }
        }
    }
}

extension BotEditorData {
    static func == (lhs: BotEditorData, rhs: BotEditorData) -> Bool {
        return lhs.branch == rhs.branch &&
            lhs.scheme == rhs.scheme &&
            lhs.buildConfig == rhs.buildConfig &&
            lhs.additionalBuildArguments == rhs.additionalBuildArguments &&
            lhs.name == rhs.name &&
            lhs.performsAnalyzeAction == rhs.performsAnalyzeAction &&
            lhs.performsTestAction == rhs.performsTestAction &&
            lhs.performsArchiveAction == rhs.performsArchiveAction &&
            lhs.performsUpgradeIntegration == rhs.performsUpgradeIntegration &&
            lhs.disableAppThinning == rhs.disableAppThinning &&
            lhs.exportsProductFromArchive == rhs.exportsProductFromArchive &&
            lhs.scheduleType == rhs.scheduleType &&
            lhs.triggerScripts == rhs.triggerScripts &&
            lhs.environmentVariables == rhs.environmentVariables &&
            lhs.exportOptions == rhs.exportOptions &&
            lhs.testDevices == rhs.testDevices
    }
}

extension BotEditorData {
    func setup(with bot: BotViewModel, updateSnapshot: Bool = true) {
        branch = bot.sourceControlBranch
        scheme = bot.schemeName
        buildConfig = bot.buildConfiguration
        additionalBuildArguments = bot.additionalBuildArguments
        name = bot.nameString
        performsAnalyzeAction = bot.performsAnalyzeAction
        performsTestAction = bot.performsTestAction
        performsArchiveAction = bot.performsArchiveAction
        performsUpgradeIntegration = bot.performsUpgradeIntegration
        disableAppThinning = bot.disableAppThinning
        exportsProductFromArchive = bot.exportsProductFromArchive
        scheduleType = bot.scheduleTypeAsString
        triggerScripts = bot.triggerScripts
        var vars = [VariablePair]()
        for (key, value) in bot.buildEnvironmentVariables {
            vars.append(VariablePair(id: key, value: value))
        }
        environmentVariables = vars
        exportOptions = bot.archiveExportOptions
        testDevices = bot.testDevices
        
        if updateSnapshot {
            let newSnapShot = BotEditorData()
            newSnapShot.setup(with: bot, updateSnapshot: false)
            snapShot = newSnapShot
        }
    }
}

extension Bot {
    func applying(_ editableData: BotEditorData) -> RequestBodyParameterProvider {
        var duplicate = self
        duplicate.requiresUpgrade = false
        duplicate.duplicatedFrom = id
        
        duplicate.id = nil
        duplicate.rev = nil
        duplicate.tinyID = nil
        duplicate.docType = nil
        duplicate.integrationCounter = nil
        duplicate.lastRevisionBlueprint = nil
        duplicate.sourceControlBlueprintIdentifier = nil
        
        duplicate.configuration?.sourceControlBlueprint?.identifierKey = UUID().uuidString
        let srcCtrlId = duplicate.configuration?.sourceControlBlueprint?.primaryRemoteRepositoryKey ?? ""
        duplicate.configuration?.sourceControlBlueprint?.locationsKey?[srcCtrlId]?.branchIdentifierKey = editableData.branch
        if !(editableData.exportOptions.name?.isEmpty == true) {
            duplicate.configuration?.archiveExportOptions = editableData.exportOptions
        }
        duplicate.name = editableData.name
        if !editableData.scheme.isEmpty {
            duplicate.configuration?.schemeName = editableData.scheme
        }
        if !editableData.buildConfig.isEmpty {
            duplicate.configuration?.buildConfiguration = editableData.buildConfig
        }
        if !editableData.additionalBuildArguments.isEmpty {
            duplicate.configuration?.additionalBuildArguments = [editableData.additionalBuildArguments]
        } else {
            duplicate.configuration?.additionalBuildArguments = []
        }
        duplicate.configuration?.performsAnalyzeAction = editableData.performsAnalyzeAction
        duplicate.configuration?.performsTestAction = editableData.performsTestAction
        duplicate.configuration?.performsArchiveAction = editableData.performsArchiveAction
        duplicate.configuration?.performsUpgradeIntegration = editableData.performsUpgradeIntegration
        duplicate.configuration?.disableAppThinning = editableData.disableAppThinning
        duplicate.configuration?.exportsProductFromArchive = editableData.exportsProductFromArchive
        duplicate.configuration?.scheduleType = ScheduleType.allCases.first { $0.string == editableData.scheduleType } ?? ScheduleType.manually
        
        var newTriggerScripts = [Trigger]()
        for triggerScript in editableData.triggerScripts {
            guard var oldTrigger = duplicate.configuration?.triggers?.first(where: { $0.name == triggerScript.name }) else {
                continue
            }
            oldTrigger.scriptBody = triggerScript.script
            newTriggerScripts.append(oldTrigger)
        }
        duplicate.configuration?.triggers = newTriggerScripts
        
        var vars = [String: String]()
        for pair in editableData.environmentVariables {
            vars[pair.id] = pair.value
        }
        duplicate.configuration?.buildEnvironmentVariables = vars
        
        let oldfilters = duplicate.configuration?.deviceSpecification?.filters
        duplicate.configuration?.deviceSpecification = TestDeviceSpecification(
            deviceIdentifiers: Array(editableData.testDevices.keys),
            filters: oldfilters
        )
        
        return duplicate
    }
}
