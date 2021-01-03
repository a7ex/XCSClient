//
//  CDTriggerConditions+Codable.swift
//  XCSClient
//
//  Created by Alex da Franca on 28.12.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import Foundation
import CoreData

extension CDTriggerConditions {
    func update(with conditions: TriggerConditions) {
        onAllIssuesResolved = conditions.onAllIssuesResolved ?? false
        onAnalyzerWarnings = conditions.onAnalyzerWarnings ?? false
        onBuildErrors = conditions.onBuildErrors ?? false
        onFailingTests = conditions.onFailingTests ?? false
        onSuccess = conditions.onSuccess ?? false
        onWarnings = conditions.onWarnings ?? false
        status = Int16(conditions.status ?? 0)
    }
}

extension CDTriggerConditions {
    var asCodableObject: TriggerConditions {
        return TriggerConditions(
            onAllIssuesResolved: onAllIssuesResolved,
            onAnalyzerWarnings: onAnalyzerWarnings,
            onBuildErrors: onBuildErrors,
            onFailingTests: onFailingTests,
            onSuccess: onSuccess,
            onWarnings: onWarnings,
            status: Int(status)
        )
    }
}
