//
//  IntegrationDetailView.swift
//  XCSClient
//
//  Created by Alex da Franca on 13.06.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import SwiftUI

struct IntegrationDetailView: View {
    let integration: IntegrationVM
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Integration \(integration.tinyID) (\(integration.number)) - \(integration.currentStep)")
                    .font(.headline)
                Divider()
                Group {
                    LabeledStringValue(label: "Result", value: integration.result)
                    LabeledStringValue(label: "Bot", value: integration.botName)
                    LabeledStringValue(label: "Duration", value: integration.duration)
                    LabeledStringValue(label: "Queued at", value: integration.queuedDate)
                    LabeledStringValue(label: "Started at", value: integration.startedTime)
                    LabeledStringValue(label: "Ended at", value: integration.endedTime)
                }
                Group {
                    LabeledStringValue(label: "Number of errors", value: integration.errorCount)
                    LabeledStringValue(label: "Number of warnings", value: integration.warningCount)
                    LabeledStringValue(label: "Number of analyzer warnings", value: integration.analyzerWarnings)
                    LabeledStringValue(label: "Number of tests", value: integration.testsCount)
                    LabeledStringValue(label: "Number of failed tests", value: integration.testFailureCount)
                    LabeledStringValue(label: "Code Coverage percentage", value: integration.codeCoverage)
                    LabeledStringValue(label: "Performance Test changes", value: integration.performanceTests)
                }
                Spacer()
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct IntegrationDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let integration = Integration(id: UUID().uuidString, rev: "", assets: nil, bot: nil, buildResultSummary: BuildResultSummary(analyzerWarningChange: 0, analyzerWarningCount: 0, codeCoveragePercentage: 0, codeCoveragePercentageDelta: 0, errorChange: 0, errorCount: 0, improvedPerfTestCount: 0, regressedPerfTestCount: 0, testFailureChange: 0, testFailureCount: 0, testsChange: 0, testsCount: 0, warningChange: 0, warningCount: 0), buildServiceFingerprint: "", ccPercentage: 0, ccPercentageDelta: 0, currentStep: "completed", docType: "", duration: 230, endedTime: Date(), number: 1, queuedDate: nil, result: IntegrationResult.buildErrors, startedTime: Date().advanced(by: 120), testedDevices: nil, tinyID: "1817142698624")
        return IntegrationDetailView(integration: IntegrationVM(integration: integration))
    }
}
