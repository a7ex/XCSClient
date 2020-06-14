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
    @EnvironmentObject var connector: XCSConnector
    
    @State private var hasError = false
    @State private var errorMessage = ""
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack {
                    Text("Integration \(integration.tinyID) (\(integration.number)) - \(integration.currentStep)")
                        .font(.headline)
                    Spacer()
                    MenuButton(label: Text("⚙️")) {
                        Button(action: { self.export(self.integration) }) {
                            Text("Download all assets…")
                        }
                    }
                    .menuButtonStyle(BorderlessPullDownMenuButtonStyle())
                    .frame(width: 30)
                }
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
                Group {
                    if integration.archive.size > 0 {
                        Button(action: { self.downloadAsset(self.integration.archive) }) {
                            Text(integration.archive.title)
                                .frame(width: 240)
                        }
                    }
                    if integration.buildServiceLog.size > 0 {
                        Button(action: { self.downloadAsset(self.integration.buildServiceLog) }) {
                            Text(integration.buildServiceLog.title)
                                .frame(width: 240)
                        }
                    }
                    if integration.sourceControlLog.size > 0 {
                        Button(action: { self.downloadAsset(self.integration.sourceControlLog) }) {
                            Text(integration.sourceControlLog.title)
                                .frame(width: 240)
                        }
                    }
                    if integration.xcodebuildLog.size > 0 {
                        Button(action: { self.downloadAsset(self.integration.xcodebuildLog) }) {
                            Text(integration.xcodebuildLog.title)
                                .frame(width: 240)
                        }
                    }
                    if integration.xcodebuildOutput.size > 0 {
                        Button(action: { self.downloadAsset(self.integration.xcodebuildOutput) }) {
                            Text(integration.xcodebuildOutput.title)
                                .frame(width: 240)
                        }
                    }
                    ForEach(integration.triggerAssets, id: \.path) { asset in
                        Button(action: { self.downloadAsset(asset) }) {
                            Text(asset.title)
                                .frame(width: 240)
                        }
                    }
                }
                .alert(isPresented: $hasError) {
                    Alert(title: Text(errorMessage))
                }
                Spacer()
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func export(_ integration: IntegrationVM) {
        connector.exportIntegrationAssets(of: integration.integrationModel) { (result) in
            switch result {
                case .success(let success):
                    print("Download success = \(success)")
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.hasError = true
            }
        }
    }
    
    private func downloadAsset(_ asset: FileDescriptor) {
        if asset.size < 500000 { // 500 KB
            connector.loadAsset(at: asset.path) { (result) in
                switch result {
                    case .success(let logData):
                        let panel = NSSavePanel()
                        panel.nameFieldStringValue = asset.name
                        let result = panel.runModal()
                        if result == .OK,
                            let url = panel.url {
                            do {
                                try logData.write(to: url)
                            } catch {
                                self.errorMessage = error.localizedDescription
                                self.hasError = true
                            }
                        }
                    case .failure(let error):
                        self.errorMessage = error.localizedDescription
                        self.hasError = true
                }
            }
        } else {
            connector.downloadAssets(at: asset.path, filename: asset.name) { (result) in
                switch result {
                    case .success(let success):
                        print("Download success = \(success)")
                    case .failure(let error):
                        self.errorMessage = error.localizedDescription
                        self.hasError = true
                }
            }
        }
    }
}

struct IntegrationDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let integration = Integration(id: UUID().uuidString, rev: "", assets: nil, bot: nil, buildResultSummary: BuildResultSummary(analyzerWarningChange: 0, analyzerWarningCount: 0, codeCoveragePercentage: 0, codeCoveragePercentageDelta: 0, errorChange: 0, errorCount: 0, improvedPerfTestCount: 0, regressedPerfTestCount: 0, testFailureChange: 0, testFailureCount: 0, testsChange: 0, testsCount: 0, warningChange: 0, warningCount: 0), buildServiceFingerprint: "", ccPercentage: 0, ccPercentageDelta: 0, currentStep: "completed", docType: "", duration: 230, endedTime: Date(), number: 1, queuedDate: nil, result: IntegrationResult.buildErrors, startedTime: Date().advanced(by: 120), testedDevices: nil, tinyID: "1817142698624")
        return IntegrationDetailView(integration: IntegrationVM(integration: integration))
    }
}
