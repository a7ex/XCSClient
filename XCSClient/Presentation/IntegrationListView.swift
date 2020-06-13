//
//  IntegrationListView.swift
//  XCSClient
//
//  Created by Alex da Franca on 12.06.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import SwiftUI

struct IntegrationListView: View {
    let integrations: [Integration]
    
    var body: some View {
        VStack {
            ForEach(integrations, id: \.tinyID) { integration in
                SingleIntegration(integration: integration)
            }
            Spacer()
        }
        .padding(.all)
    }
}

struct SingleIntegration: View {
    let integration: Integration
    
    var body: some View {
        HStack {
            NavigationLink(destination: IntegrationDetailView(integration: integration)) {
            Text(integration.tinyID ?? "- missing -")
            }
        }
    }
}

struct IntegrationListView_Previews: PreviewProvider {
    static var previews: some View {
        IntegrationListView(integrations: [
            Integration(id: UUID().uuidString, rev: "", assets: nil, bot: nil, buildResultSummary: BuildResultSummary(analyzerWarningChange: 0, analyzerWarningCount: 0, codeCoveragePercentage: 0, codeCoveragePercentageDelta: 0, errorChange: 0, errorCount: 0, improvedPerfTestCount: 0, regressedPerfTestCount: 0, testFailureChange: 0, testFailureCount: 0, testsChange: 0, testsCount: 0, warningChange: 0, warningCount: 0), buildServiceFingerprint: "", ccPercentage: 0, ccPercentageDelta: 0, currentStep: "completed", docType: "", duration: 230, endedTime: Date(), number: 1, result: IntegrationResult.buildErrors, startedTime: Date().advanced(by: 120), testedDevices: nil, tinyID: "1"),
            Integration(id: UUID().uuidString, rev: "", assets: nil, bot: nil, buildResultSummary: BuildResultSummary(analyzerWarningChange: 0, analyzerWarningCount: 0, codeCoveragePercentage: 0, codeCoveragePercentageDelta: 0, errorChange: 0, errorCount: 0, improvedPerfTestCount: 0, regressedPerfTestCount: 0, testFailureChange: 0, testFailureCount: 0, testsChange: 0, testsCount: 0, warningChange: 0, warningCount: 0), buildServiceFingerprint: "", ccPercentage: 0, ccPercentageDelta: 0, currentStep: "completed", docType: "", duration: 230, endedTime: Date(), number: 1, result: IntegrationResult.buildErrors, startedTime: Date().advanced(by: 120), testedDevices: nil, tinyID: "2")
        ])
    }
}
