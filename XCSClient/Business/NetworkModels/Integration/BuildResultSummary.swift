//
//  BuildResultSummary.swift
//  xcodeserverclient
//
//  Created by Alex da Franca on 11.06.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import Foundation

struct BuildResultSummary: Codable {
    let analyzerWarningChange: Int? // 0,
    let analyzerWarningCount: Int? // 0,
    let codeCoveragePercentage: Int? // 0,
    let codeCoveragePercentageDelta: Int? // 0,
    let errorChange: Int? // 2,
    let errorCount: Int? // 2,
    let improvedPerfTestCount: Int? // 0,
    let regressedPerfTestCount: Int? // 0,
    let testFailureChange: Int? // 0,
    let testFailureCount: Int? // 0,
    let testsChange: Int? // 0,
    let testsCount: Int? // 0,
    let warningChange: Int? // 0,
    let warningCount: Int? // 0
}
