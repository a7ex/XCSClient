//
//  CDIntegrationAssets+Codable.swift
//  XCSClient
//
//  Created by Alex da Franca on 27.12.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import Foundation
import CoreData

extension CDIntegrationAssets {
    func update(with assets: IntegrationAssets) {
        guard let context = managedObjectContext else {
            fatalError("Wir haben hier keinen context!!")
        }
        
        if let assetArchives = assets.archive {
            let archs = CDLogFile(context: context)
            archs.update(with: assetArchives)
            archive = archs
        } else {
            archive = nil
        }
        
        if let bsLog = assets.buildServiceLog {
            let archs = CDLogFile(context: context)
            archs.update(with: bsLog)
            buildServiceLog = archs
        } else {
            buildServiceLog = nil
        }
        
        if let srcLog = assets.sourceControlLog {
            let archs = CDLogFile(context: context)
            archs.update(with: srcLog)
            sourceControlLog = archs
        } else {
            sourceControlLog = nil
        }
        
        if let trigAssets = assets.triggerAssets {
            if let trgs = triggerAssets {
                removeFromTriggerAssets(trgs)
            }
            for thisAsset in trigAssets {
                let archs = CDLogFile(context: context)
                archs.update(with: thisAsset)
                addToTriggerAssets(archs)
            }
        } else {
            triggerAssets = nil
        }
        
        if let buildLog = assets.xcodebuildLog {
            let archs = CDLogFile(context: context)
            archs.update(with: buildLog)
            xcodebuildLog = archs
        } else {
            xcodebuildLog = nil
        }
        
        if let output = assets.xcodebuildOutput {
            let archs = CDLogFile(context: context)
            archs.update(with: output)
            xcodebuildOutput = archs
        } else {
            xcodebuildOutput = nil
        }
    }
}
