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
    
    @State private var durationInSeconds = "0"
    private let timer = Timer.publish(every: 1, tolerance: 0.5, on: .main, in: .common).autoconnect()
    
    private func timeSpanFromNow(to startDate: Date?) -> String {
        guard let startDate = startDate else {
            return ""
        }
        
        if !integration.endedTime.isEmpty {
            timer.upstream.connect().cancel()
            return integration.duration
        }
        
        let interval = startDate.timeIntervalSinceNow * -1
        if (Int(interval) % 10) == 0 {
            refreshLastIntegration(of: integration.botId)
        }
        let fmt = DateComponentsFormatter()
        return fmt.string(from: interval) ?? ""
    }
    
    private func refreshLastIntegration(of botId: String) {
        connector.getIntegrationsList(for: botId, last: 1) { (result) in
            if case let .success(integrations) = result {
                if let integration = integrations.first,
                    let result = integration.result,
                    result == .unknown {
//                    self.integration.integrationModel = integration
                }
            }
        }
    }
    
    
    var body: some View {
        ZStack {
            VStack() {
                HStack {
                    Text("●")
                        .foregroundColor(integration.statusColor)
                    Text("Integration \(integration.tinyID) (\(integration.number)) - \(integration.result)")
                        .font(.headline)
                }
                Divider()
                Group {
                    UpdatingStatusText(currentStatus: integration.currentStep, botId: integration.botId)
                        .font(.subheadline)
                        .padding(.bottom, 8)
                    LabeledStringValue(label: "Result", value: integration.result)
                    LabeledStringValue(label: "ID", value: integration.id)
                    LabeledStringValue(label: "Bot", value: integration.botName)
                    LabeledStringValue(label: "Date", value: integration.startDate)
                    if !integration.startTimes.isEmpty {
                        LabeledStringValue(label: "Start time", value: integration.startTimes)
                    }
                    if !integration.endedTime.isEmpty {
                        LabeledStringValue(label: "End time", value: integration.endedTime)
                    }
                    if integration.integrationModel.startedTime != nil {
                        LabeledStringValue(label: "Duration", value: durationInSeconds)
                            .onReceive(timer) { (timer) in
                                self.durationInSeconds = self.timeSpanFromNow(to: self.integration.integrationModel.startedTime)
                        }
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
                    if integration.result == IntegrationResult.unknown.rawValue {
                        Button(action: { self.cancelIntegration(self.integration.id) }) {
                            ButtonLabel(text: "Cancel integration")
                        }
                    }
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
        .onAppear {
            
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
                    if let str = String(data: logData, encoding: .utf8) {
                        self.openTextWindow(with: str, windowTitle: asset.name)
                    } else if let url = self.getSaveURLFromUser(for: asset.name) {
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
    
    private func cancelIntegration(_ integrationId: String) {
        guard !integrationId.isEmpty else {
            return
        }
        connector.cancelIntegration(integrationId) { (result) in
            switch result {
            case .success(let success):
                self.errorMessage = success ? "Integration successfully cancelled": "Failed to cancel integration"
                self.hasError = true
            case .failure(let error):
                self.errorMessage = error.localizedDescription
                self.hasError = true
            }
        }
    }
    
    private func openTextWindow(with textContent: String, windowTitle: String = "Unnamed") {
        let sb = NSStoryboard(name: "Main", bundle: nil)
        if let windowController = sb.instantiateController(withIdentifier: "TextEditorWindow") as? NSWindowController,
            let controller = windowController.contentViewController as? SimpleTextViewController {
            controller.stringContent = textContent
            windowController.window?.title = windowTitle
            windowController.showWindow(nil)
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
        
        let connector = XCSConnector(server: Server(xcodeServerAddress: XcodeServer.miniAgent03.ipAddress, sshEndpoint: "adafranca@10.175.31.236"), name: "Mac Mini 01")
        
        return IntegrationDetailView(integration: IntegrationVM(integration: integration))
            .environmentObject(connector)
    }
}
