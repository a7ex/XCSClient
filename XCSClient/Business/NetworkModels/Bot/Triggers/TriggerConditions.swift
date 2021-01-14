//
//  TriggerConditions.swift
//  xcodeserverclient
//
//  Created by Alex da Franca on 04.06.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import Foundation

struct TriggerConditions: Codable {
    var onAllIssuesResolved: Bool?
    var onAnalyzerWarnings: Bool?
    var onBuildErrors: Bool?
    var onFailingTests: Bool?
    var onSuccess: Bool?
    var onWarnings: Bool?
    var status: Int?
    
    static var allOn: TriggerConditions {
        return TriggerConditions(
            onAllIssuesResolved: true,
            onAnalyzerWarnings: true,
            onBuildErrors: true,
            onFailingTests: true,
            onSuccess: true,
            onWarnings: true,
            status: 0
        )
    }
}
