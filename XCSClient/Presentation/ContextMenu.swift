//
//  ContextMenu.swift
//  XCSClient
//
//  Created by Alex da Franca on 13.06.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import SwiftUI

struct ContextMenu: View {
    let integrations: [String: IntegrationsData]
    
    var body: some View {
        List(0...3, id: \.self) { num in
            VStack(alignment: .leading) {
                Text("Irgendwas \(num)")
                    .background(Color.gray)
                    .foregroundColor(.white)
                
                Section {
                    ForEach(self.integrations["botId"]?.integrations ?? [Integration](), id: \.id) { thisInt in
                        Text("Irgendwas \(thisInt.id)")
                            .background(Color.red)
                            .foregroundColor(.white)
                            .padding(.leading, 16)
                    }
                }
            }
        }
    }
}

struct ContextMenu_Previews: PreviewProvider {
    static var previews: some View {
        let integrations = [
            Integration(id: UUID().uuidString, rev: "", assets: nil, bot: nil, buildResultSummary: BuildResultSummary(analyzerWarningChange: 0, analyzerWarningCount: 0, codeCoveragePercentage: 0, codeCoveragePercentageDelta: 0, errorChange: 0, errorCount: 0, improvedPerfTestCount: 0, regressedPerfTestCount: 0, testFailureChange: 0, testFailureCount: 0, testsChange: 0, testsCount: 0, warningChange: 0, warningCount: 0), buildServiceFingerprint: "", ccPercentage: 0, ccPercentageDelta: 0, currentStep: "completed", docType: "", duration: 230, endedTime: Date(), number: 1, result: IntegrationResult.buildErrors, startedTime: Date().advanced(by: 120), testedDevices: nil, tinyID: "1"),
            Integration(id: UUID().uuidString, rev: "", assets: nil, bot: nil, buildResultSummary: BuildResultSummary(analyzerWarningChange: 0, analyzerWarningCount: 0, codeCoveragePercentage: 0, codeCoveragePercentageDelta: 0, errorChange: 0, errorCount: 0, improvedPerfTestCount: 0, regressedPerfTestCount: 0, testFailureChange: 0, testFailureCount: 0, testsChange: 0, testsCount: 0, warningChange: 0, warningCount: 0), buildServiceFingerprint: "", ccPercentage: 0, ccPercentageDelta: 0, currentStep: "completed", docType: "", duration: 230, endedTime: Date(), number: 1, result: IntegrationResult.buildErrors, startedTime: Date().advanced(by: 120), testedDevices: nil, tinyID: "2")
        ]
        let data = IntegrationsData(botId: "12345", integrations: integrations)
        return ContextMenu(integrations: [
            "botId": data
        ])
    }
}
