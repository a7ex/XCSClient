//
//  BuildResultSummary.swift
//  xcodeserverclient
//
//  Created by Alex da Franca on 11.06.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import Foundation

struct BuildResultSummary: Codable {
    let analyzerWarningChange: Int?
    let analyzerWarningCount: Int?
    let codeCoveragePercentage: Int?
    let codeCoveragePercentageDelta: Int?
    let errorChange: Int?
    let errorCount: Int?
    let improvedPerfTestCount: Int?
    let regressedPerfTestCount: Int?
    let testFailureChange: Int?
    let testFailureCount: Int?
    let testsChange: Int?
    let testsCount: Int?
    let warningChange: Int?
    let warningCount: Int?}
