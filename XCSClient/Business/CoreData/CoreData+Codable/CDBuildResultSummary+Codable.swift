//
//  CDBuildResultSummary+Codable.swift
//  XCSClient
//
//  Created by Alex da Franca on 27.12.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import Foundation
import CoreData

extension CDBuildResultSummary {
    func update(with buildSummary: BuildResultSummary) {
        analyzerWarningChange = Int16(buildSummary.analyzerWarningChange ?? 0)
        analyzerWarningCount = Int16(buildSummary.analyzerWarningCount ?? 0)
        codeCoveragePercentage = Int16(buildSummary.codeCoveragePercentage ?? 0)
        codeCoveragePercentageDelta = Int16(buildSummary.codeCoveragePercentageDelta ?? 0)
        errorChange = Int16(buildSummary.errorChange ?? 0)
        errorCount = Int16(buildSummary.errorCount ?? 0)
        improvedPerfTestCount = Int16(buildSummary.improvedPerfTestCount ?? 0)
        regressedPerfTestCount = Int16(buildSummary.regressedPerfTestCount ?? 0)
        testFailureChange = Int16(buildSummary.testFailureChange ?? 0)
        testFailureCount = Int16(buildSummary.testFailureCount ?? 0)
        testsChange = Int16(buildSummary.testsChange ?? 0)
        testsCount = Int16(buildSummary.testsCount ?? 0)
        warningChange = Int16(buildSummary.warningChange ?? 0)
        warningCount = Int16(buildSummary.warningCount ?? 0)
    }
}
