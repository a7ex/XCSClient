//
//  CDSourceControlBlueprint+Codable.swift
//  XCSClient
//
//  Created by Alex da Franca on 27.12.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import Foundation
import CoreData

extension CDSourceControlBlueprint {
    func update(with blueprint: SourceControlBlueprint) {
        identifierKey = blueprint.identifierKey
        
        if let locs = locations {
            removeFromLocations(locs)
        }
        if let locations = blueprint.locationsKey {
            if let context = managedObjectContext {
                for (key, value) in locations {
                    let loc = CDSourceControlLocation(context: context)
                    loc.update(with: value)
                    let newLoc = CDSingleSourceControlLocation(context: context)
                    newLoc.key = key
                    newLoc.value = loc
                    addToLocations(newLoc)
                }
            } else {
                fatalError("Wir haben hier keinen context!!")
            }
        }
        nameKey = blueprint.nameKey
        primaryRemoteRepositoryKey = blueprint.primaryRemoteRepositoryKey
        relativePathToProjectKey = blueprint.relativePathToProjectKey
        remoteRepositoryAuthenticationStrategiesKey = blueprint.remoteRepositoryAuthenticationStrategiesKey
        version = Int32(blueprint.version ?? 0)
        workingCopyPathsKey = blueprint.workingCopyPathsKey
        workingCopyStatesKey = blueprint.workingCopyStatesKey
        
        if let reps = remoteRepositoriesKey {
            removeFromRemoteRepositoriesKey(reps)
        }
        if let context = managedObjectContext {
            blueprint.remoteRepositoriesKey?.forEach { input in
                let newRep = CDRemoteRepository(context: context)
                newRep.update(with: input)
                addToRemoteRepositoriesKey(newRep)
            }
        } else {
            fatalError("Wir haben hier keinen context!!")
        }
    }
}

extension CDSourceControlBlueprint {
    var asCodableObject: SourceControlBlueprint {
        var locationsDict: [String: SourceControlLocation]?
        if let locations = locations {
            locationsDict = [String: SourceControlLocation]()
            for location in locations {
                if let location = location as? CDSingleSourceControlLocation,
                   let key = location.key,
                   let thisLocation = location.value {
                    locationsDict?[key] = thisLocation.asCodableObject
                }
            }
        } else {
            locationsDict = nil
        }
        let repArray = Array(remoteRepositoriesKey ?? NSSet()) as? [CDRemoteRepository]
        let newReps = repArray?.map { $0.asCodableObject }
        
        return SourceControlBlueprint(
            identifierKey: identifierKey,
            locationsKey: locationsDict,
            nameKey: nameKey,
            primaryRemoteRepositoryKey: primaryRemoteRepositoryKey,
            relativePathToProjectKey: relativePathToProjectKey,
            remoteRepositoriesKey: newReps,
            remoteRepositoryAuthenticationStrategiesKey: remoteRepositoryAuthenticationStrategiesKey,
            version: Int(version),
            workingCopyPathsKey: workingCopyPathsKey,
            workingCopyStatesKey: workingCopyStatesKey
        )
    }
}
