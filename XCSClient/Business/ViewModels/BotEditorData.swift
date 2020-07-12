//
//  BotEditorData.swift
//  XCSClient
//
//  Created by Alex da Franca on 12.07.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import SwiftUI

class BotEditorData: ObservableObject {
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
    
    func setup(with bot: BotVM) {
        branch = bot.sourceControlBranch
        scheme = bot.schemeName
        buildConfig = bot.buildConfiguration
        additionalBuildArguments = bot.additionalBuildArguments
        name = bot.name
        performsAnalyzeAction = bot.performsAnalyzeAction
        performsTestAction = bot.performsTestAction
        performsArchiveAction = bot.performsArchiveAction
        performsUpgradeIntegration = bot.performsUpgradeIntegration
        disableAppThinning = bot.disableAppThinning
        exportsProductFromArchive = bot.exportsProductFromArchive
        scheduleType = bot.scheduleType
        triggerScripts = bot.triggerScripts
    }
}

extension Bot {
    func applying(_ editableData: BotEditorData) -> Bot {
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
        
        return duplicate
    }
}
