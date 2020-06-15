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
    @State private var activityShowing = false
    
    var body: some View {
        ZStack {
            VStack() {
                Text("Integration \(integration.tinyID) (\(integration.number)) - \(integration.currentStep)")
                        .font(.headline)
                Divider()
                Group {
                    LabeledStringValue(label: "Result", value: integration.result)
                    LabeledStringValue(label: "Bot", value: integration.botName)
                    LabeledStringValue(label: "Duration", value: integration.duration)
                    LabeledStringValue(label: "Date", value: integration.startDate)
                    if !integration.startEndTimes.isEmpty {
                        LabeledStringValue(label: "Time", value: integration.startEndTimes)
                    }
                    if !integration.sourceControlCommitId.isEmpty {
                    LabeledStringValue(label: "Commit ID", value: integration.sourceControlCommitId)
                    }
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
                Divider()
                Group {
                    if integration.archive.size > 0 {
                        Button(action: { self.downloadAsset(self.integration.archive) }) {
                            ButtonLabel(text: integration.archive.title)
                        }
                    }
                    if integration.buildServiceLog.size > 0 {
                        Button(action: { self.downloadAsset(self.integration.buildServiceLog) }) {
                            ButtonLabel(text: integration.buildServiceLog.title)
                        }
                    }
                    if integration.sourceControlLog.size > 0 {
                        Button(action: { self.downloadAsset(self.integration.sourceControlLog) }) {
                            ButtonLabel(text: integration.sourceControlLog.title)
                        }
                    }
                    if integration.xcodebuildLog.size > 0 {
                        Button(action: { self.downloadAsset(self.integration.xcodebuildLog) }) {
                            ButtonLabel(text: integration.xcodebuildLog.title)
                        }
                    }
                    if integration.xcodebuildOutput.size > 0 {
                        Button(action: { self.downloadAsset(self.integration.xcodebuildOutput) }) {
                            ButtonLabel(text: integration.xcodebuildOutput.title)
                        }
                    }
                    ForEach(integration.triggerAssets, id: \.path) { asset in
                        Button(action: { self.downloadAsset(asset) }) {
                            ButtonLabel(text: asset.title)
                        }
                    }
                    Button(action: { self.export(self.integration) }) {
                        ButtonLabel(text: "Download all assets as archive…")
                    }
                }
                .alert(isPresented: $hasError) {
                    Alert(title: Text(errorMessage))
                }
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            if activityShowing {
                Color.black
                    .opacity(0.5)
                VStack {
                    ActivityIndicator()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.white)
                    Text("Loading…")
                        .foregroundColor(.white)
                }
            }
        }
    }
    
    private func export(_ integration: IntegrationVM) {
        guard let url = getSaveURLFromUser(for: "Results-\(integration.tinyID).tgz") else {
            return
        }
        withAnimation {
            self.activityShowing = true
        }
        connector.exportIntegrationAssets(of: integration.integrationModel, to: url) { (result) in
            withAnimation {
                self.activityShowing = false
            }
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
            withAnimation {
                self.activityShowing = true
            }
            connector.loadAsset(at: asset.path) { (result) in
                withAnimation {
                    self.activityShowing = false
                }
                switch result {
                    case .success(let logData):
                        if let url = self.getSaveURLFromUser(for: asset.name) {
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
            guard let url = getSaveURLFromUser(for: asset.name) else {
                return
            }
            withAnimation {
                self.activityShowing = true
            }
            connector.downloadAssets(at: asset.path, to: url) { (result) in
                withAnimation {
                    self.activityShowing = false
                }
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
    
    // MARK: - Helper
    
    func getSaveURLFromUser(for fileName: String) -> URL? {
        let panel = NSSavePanel()
        panel.nameFieldStringValue = fileName
        let result = panel.runModal()
        guard result == .OK else {
            return nil
        }
        return panel.url
    }
}

struct IntegrationDetailView_Previews: PreviewProvider {
    static var previews: some View {
        
        let logfile = LogFile(allowAnonymousAccess: true, fileName: "Source Control Logs", isDirectory: false, relativePath: "NotEmpty", size: 3474)
        let logfile2 = LogFile(allowAnonymousAccess: true, fileName: "Archive", isDirectory: false, relativePath: "NotEmpty", size: 143456474)
        let logfile3 = LogFile(allowAnonymousAccess: true, fileName: "Ein ganz langer Name", isDirectory: false, relativePath: "NotEmpty", size: 34536474)
        
        let assets = IntegrationAssets(archive: logfile, buildServiceLog: logfile2, sourceControlLog: logfile3, xcodebuildLog: logfile2, xcodebuildOutput: logfile, triggerAssets: [logfile3])
        
        let integration = Integration(id: UUID().uuidString, rev: "", assets: assets, bot: nil, buildResultSummary: BuildResultSummary(analyzerWarningChange: 0, analyzerWarningCount: 0, codeCoveragePercentage: 0, codeCoveragePercentageDelta: 0, errorChange: 0, errorCount: 0, improvedPerfTestCount: 0, regressedPerfTestCount: 0, testFailureChange: 0, testFailureCount: 0, testsChange: 0, testsCount: 0, warningChange: 0, warningCount: 0), buildServiceFingerprint: "", ccPercentage: 0, ccPercentageDelta: 0, currentStep: "completed", docType: "", duration: 230, endedTime: Date(), number: 1, queuedDate: nil, result: IntegrationResult.buildErrors, startedTime: Date().advanced(by: 120), testedDevices: nil, tinyID: "1817142698624")
        
        return IntegrationDetailView(integration: IntegrationVM(integration: integration))
    }
}
