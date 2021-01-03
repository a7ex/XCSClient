//
//  CDBotConfiguration+Codable.swift
//  XCSClient
//
//  Created by Alex da Franca on 27.12.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import Foundation
import CoreData

extension CDBotConfiguration {
    var scheduleType: ScheduleType {
        return ScheduleType(rawValue: Int(scheduleTypeValue)) ?? .none
    }
    var periodicScheduleInterval: PeriodicScheduleInterval {
        return PeriodicScheduleInterval(rawValue: Int(periodicScheduleIntervalValue)) ?? .none
    }
    var weeklyScheduleDay: WeeklyScheduleDay {
        return WeeklyScheduleDay(rawValue: Int(weeklyScheduleDayValue)) ?? .none
    }
    func update(with configuration: BotConfiguration) {
        additionalBuildArguments = configuration.additionalBuildArguments
        buildEnvironmentVariables = configuration.buildEnvironmentVariables
        additionalBuildArguments = configuration.additionalBuildArguments
        buildConfiguration = configuration.buildConfiguration
        buildEnvironmentVariables = configuration.buildEnvironmentVariables
        builtFromCleanValue = Int16(configuration.builtFromClean ?? 0)
        codeCoveragePreferenceValue = Int16(configuration.codeCoveragePreference?.rawValue ?? 0)
        disableAppThinning = configuration.disableAppThinning ?? false
        exportsProductFromArchive = configuration.exportsProductFromArchive ?? false
        hourOfIntegration = Int16(configuration.hourOfIntegration ?? 0)
        minutesAfterHourToIntegrate = Int16(configuration.minutesAfterHourToIntegrate ?? 0)
        performsAnalyzeAction = configuration.performsAnalyzeAction ?? false
        performsArchiveAction = configuration.performsArchiveAction ?? false
        performsTestAction = configuration.performsTestAction ?? false
        performsUpgradeIntegration = configuration.performsUpgradeIntegration ?? false
        periodicScheduleIntervalValue = Int16(configuration.periodicScheduleInterval?.rawValue ?? 0)
        scheduleTypeValue = Int16(configuration.scheduleType?.rawValue ?? 0)
        schemeName = configuration.schemeName
        weeklyScheduleDayValue = Int16(configuration.weeklyScheduleDay?.rawValue ?? 0)
        
        if let opts = configuration.archiveExportOptions {
            if let context = managedObjectContext {
                archiveExportOptions = archiveExportOptions ?? CDArchiveExportOptions(context: context)
                archiveExportOptions?.update(with: opts)
            } else {
                fatalError("Wir haben hier keinen context!!")
            }
        } else {
            archiveExportOptions = nil
        }
        
        if let specs = configuration.deviceSpecification {
            if let context = managedObjectContext {
                deviceSpecification = deviceSpecification ?? CDTestDeviceSpecification(context: context)
                deviceSpecification?.update(with: specs)
            } else {
                fatalError("Wir haben hier keinen context!!")
            }
        } else {
            deviceSpecification = nil
        }
        
        if let conf = configuration.provisioningConfiguration {
            if let context = managedObjectContext {
                provisioningConfiguration = provisioningConfiguration ?? CDProvisioningConfiguration(context: context)
                provisioningConfiguration?.update(with: conf)
            } else {
                fatalError("Wir haben hier keinen context!!")
            }
        } else {
            provisioningConfiguration = nil
        }
        
        if let blueprint = configuration.sourceControlBlueprint {
            if let context = managedObjectContext {
                sourceControlBlueprint = sourceControlBlueprint ?? CDSourceControlBlueprint(context: context)
                sourceControlBlueprint?.update(with: blueprint)
            } else {
                fatalError("Wir haben hier keinen context!!")
            }
        } else {
            sourceControlBlueprint = nil
        }
        
        if let trigs = triggers {
            removeFromTriggers(trigs)
        }
        if let context = managedObjectContext {
            configuration.triggers?.forEach { input in
                let newTrigger = CDTrigger(context: context)
                newTrigger.update(with: input)
                addToTriggers(newTrigger)
            }
        } else {
            fatalError("Wir haben hier keinen context!!")
        }
        
    }
    
    var asCodableObject: BotConfiguration {
        let triggerArray = Array(triggers ?? NSSet()) as? [CDTrigger]
        return BotConfiguration(
            additionalBuildArguments: additionalBuildArguments,
            buildEnvironmentVariables: buildEnvironmentVariables,
            deviceSpecification: deviceSpecification?.asCodableObject,
            builtFromClean: Int(builtFromCleanValue),
            codeCoveragePreference: CodeCoveragePreference(rawValue: Int(codeCoveragePreferenceValue)),
            disableAppThinning: disableAppThinning,
            exportsProductFromArchive: exportsProductFromArchive,
            hourOfIntegration: Int(hourOfIntegration),
            minutesAfterHourToIntegrate: Int(minutesAfterHourToIntegrate),
            performsAnalyzeAction: performsAnalyzeAction,
            performsArchiveAction: performsArchiveAction,
            performsTestAction: performsTestAction,
            performsUpgradeIntegration: performsUpgradeIntegration,
            periodicScheduleInterval: PeriodicScheduleInterval(rawValue: Int(periodicScheduleIntervalValue)),
            provisioningConfiguration: provisioningConfiguration?.asCodableObject,
            runOnlyDisabledTests: nil,
            scheduleType: ScheduleType(rawValue: Int(scheduleTypeValue)),
            schemeName: schemeName,
            sourceControlBlueprint: sourceControlBlueprint?.asCodableObject,
            testLocalizations: nil,
            testingDestinationType: nil,
            triggers: triggerArray?.map { $0.asCodableObject },
            useParallelDeviceTesting: nil,
            weeklyScheduleDay: WeeklyScheduleDay(rawValue: Int(weeklyScheduleDayValue)),
            buildConfiguration: buildConfiguration,
            archiveExportOptions: archiveExportOptions?.asCodableObject
            )
    }
}
