//
//  IntegrationDetailView.swift
//  XCSClient
//
//  Created by Alex da Franca on 13.06.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import SwiftUI
import Combine

struct IntegrationDetailView: View {
    let integration: IntegrationVM
    
    @EnvironmentObject var connector: XCSConnector
    
    @State private var hasError = false
    @State private var errorMessage = ""
    @State private var activityShowing = false
    @State private var revisionInfo = RevisionInfo(snippet: "")
    @State private var ipaPath = "loading"
    @State private var machineName = ""
    
    @State private var durationInSeconds = "0"
    private let timer = Timer.publish(every: 1, tolerance: 0.5, on: .main, in: .common).autoconnect()
    
    private let fileHelper = FileHelper()
    
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
                }
                Group {
                    if !integration.endedTime.isEmpty {
                        LabeledStringValue(label: "End time", value: integration.endedTime)
                    }
                    if integration.integrationModel.startedTime != nil {
                        LabeledStringValue(label: "Duration", value: durationInSeconds)
                            .onReceive(timer) { (timer) in
                                self.durationInSeconds = self.timeSpanFromNow(to: self.integration.integrationModel.startedTime)
                        }
                    }
                    LabeledStringValue(label: "Code Coverage percentage", value: integration.codeCoverage)
                    LabeledStringValue(label: "Performance Test changes", value: integration.performanceTests)
                    if !integration.sourceControlCommitId.isEmpty {
                        LabeledStringValue(label: "Commit ID", value: integration.sourceControlCommitId)
                    }
                }
                if !revisionInfo.isEmpty {
                    Divider()
                    HStack {
                        VStack(alignment: .leading) {
                            Text(revisionInfo.author)
                            Text(revisionInfo.date)
                            Text(revisionInfo.comment)
                                .font(.headline)
                        }
                        Spacer()
                    }
                }
                Divider()
                HStack(alignment: .top) {
                    Spacer()
                    VStack {
                        Text("🐞")
                            .font(.largeTitle)
                        Text("\(integration.errorCount) Errors")
                            .font(.headline)
                        Text("(\(integration.errorChange))")
                    }
                    Spacer()
                    VStack {
                        Text("⚠️")
                            .font(.largeTitle)
                        Text("\(integration.warningCount) Warnings")
                            .font(.headline)
                        Text("(\(integration.warningChange))")
                    }
                    Spacer()
                    VStack {
                        Text("🛠")
                            .font(.largeTitle)
                        Text("\(integration.analyzerWarnings) Issues")
                            .font(.headline)
                        Text("(\(integration.analyzerWarningChange))")
                    }
                    Spacer()
                    VStack {
                        Text(integration.testFailureCount > 0 ? "❌": "✅")
                            .font(.largeTitle)
                        Text("\(integration.passedTestsCount) Passed tests")
                            .font(.headline)
                        Text("(\(integration.passedTestsChange))")
                        Text("\(integration.testFailureCount) Failed tests")
                            .font(.headline)
                        Text("(\(integration.testFailureChange))")
                    }
                    Spacer()
                }
                Divider()
                Group {
                    if integration.result == IntegrationResult.unknown.rawValue {
                        Button(action: { self.cancelIntegration(self.integration.id) }) {
                            ButtonLabel(text: "Cancel integration")
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
                    ForEach(integration.triggerAssets, id: \.path) { asset in
                        Button(action: { self.downloadAsset(asset) }) {
                            ButtonLabel(text: asset.title)
                        }
                    }
                    if integration.hasAssets {
                        Button(action: { self.export(self.integration) }) {
                            if integration.archive.size > 0 {
                                ButtonLabel(text: integration.archive.title)
                            } else {
                                ButtonLabel(text: "Logs and Test Results")
                            }
                        }
                        if integration.archive.size > 0 {
                            if ipaPath == "loading" {
                                Text("Loading path to ipa…")
                            } else {
                                if !ipaPath.isEmpty {
                                    Button(action: { self.downloadIPA() }) {
                                        ButtonLabel(text: "Download ipa")
                                    }
                                } else {
                                    Text("No ipa available.")
                                }
                            }
                        }
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
            _ = self.timer.upstream.autoconnect()
            self.loadCommitData()
            if integration.archive.size > 0 {
                self.findIpa()
            }
        }
    }
    
    private func export(_ integration: IntegrationVM) {
        guard let url = fileHelper.getSaveURLFromUser(for: "Results-\(integration.tinyID).tgz") else {
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
    
    private func loadCommitData() {
        let asset = integration.sourceControlLog
        connector.loadAsset(at: asset.path) { (result) in
            switch result {
            case .success(let logData):
                guard let str = String(data: logData, encoding: .utf8) else {
                    return
                    
                }
                let substr = str.matches(regex: "log items:\\n\\s*Revision:.+?Revision:")
                if let rev = substr.first {
                    let revString = String(rev.dropFirst(11).dropLast(10))
                    self.revisionInfo = RevisionInfo(snippet: revString)
                }
            case .failure:
                break
            }
        }
    }
    
    private func findIpa() {
        let asset = integration.buildServiceLog
        connector.loadAsset(at: asset.path) { (result) in
            switch result {
            case .success(let logData):
                guard let str = String(data: logData, encoding: .utf8),
                      let regex = try? NSRegularExpression(pattern: "\\/Users\\/(.+?)\\/", options: [.caseInsensitive, .dotMatchesLineSeparators]) else {
                    return
                }
                let matches  = regex.matches(in: str, options: [], range: NSMakeRange(0, str.count))
                guard let firstMatch = matches.first,
                      firstMatch.numberOfRanges > 1,
                      let machineNameRange = Range(firstMatch.range(at: 1), in: str) else {
                    return
                }
                machineName = String(str[machineNameRange])
                connector.findIpa(
                    machineName: machineName,
                    botID: integration.botId,
                    botName: integration.botName,
                    integrationNumber: integration.number) { path in
                    ipaPath = path
                }
            case .failure:
                break
            }
        }
    }
    
    private func downloadIPA() {
        guard !ipaPath.isEmpty else {
            return
        }
        let components = ipaPath.components(separatedBy: "/")
        guard let ipaName = components.last,
              let url = self.fileHelper.getSaveURLFromUser(for: "\(ipaName).zip") else {
            return
        }
        withAnimation {
            self.activityShowing = true
        }
        connector.scpAsset(at: ipaPath, to: url, machineName: machineName) { (result) in
            withAnimation {
                self.activityShowing = false
            }
            switch result {
            case .success(let done):
                self.errorMessage = done ? "Downloaded ipa with success.": "failed to download ipa"
                self.hasError = true
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
                    } else if let url = self.fileHelper.getSaveURLFromUser(for: asset.name) {
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
            guard let url = fileHelper.getSaveURLFromUser(for: asset.name) else {
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
}

struct IntegrationDetailView_Previews: PreviewProvider {
    static var previews: some View {
        
        let logfile = LogFile(allowAnonymousAccess: true, fileName: "Source Control Logs", isDirectory: false, relativePath: "NotEmpty", size: 3474)
        let logfile2 = LogFile(allowAnonymousAccess: true, fileName: "Archive", isDirectory: false, relativePath: "NotEmpty", size: 143456474)
        let logfile3 = LogFile(allowAnonymousAccess: true, fileName: "A very very long name", isDirectory: false, relativePath: "NotEmpty", size: 34536474)
        
        let assets = IntegrationAssets(archive: logfile, buildServiceLog: logfile2, sourceControlLog: logfile3, xcodebuildLog: logfile2, xcodebuildOutput: logfile, triggerAssets: [logfile3])
        
        let integration = Integration(id: UUID().uuidString, rev: "", assets: assets, bot: nil, buildResultSummary: BuildResultSummary(analyzerWarningChange: -3, analyzerWarningCount: 0, codeCoveragePercentage: 48, codeCoveragePercentageDelta: 5, errorChange: 0, errorCount: 0, improvedPerfTestCount: 0, regressedPerfTestCount: 0, testFailureChange: 1, testFailureCount: 2, testsChange: 0, testsCount: 80, warningChange: 0, warningCount: 10), buildServiceFingerprint: "", ccPercentage: 0, ccPercentageDelta: 0, currentStep: "completed", docType: "", duration: 230, endedTime: Date(), number: 1, queuedDate: nil, result: IntegrationResult.buildErrors, revisionBlueprint: nil, startedTime: Date().advanced(by: 120), testHierarchy: nil, testedDevices: nil, tinyID: "1817142698624")
        
        return Group {
            IntegrationDetailView(integration: IntegrationVM(integration: integration))
                .environmentObject(XCSConnector.previewServerConnector)
            //            IntegrationDetailView(integration: IntegrationVM(integration: integration))
            //                .environment(\.sizeCategory, .extraLarge)
            //                .environmentObject(XCSConnector.previewServerConnector)
        }
    }
}

private extension String {
    func matches(regex: String) -> [String] {
        guard let regex = try? NSRegularExpression(pattern: regex, options: [.caseInsensitive, .dotMatchesLineSeparators]) else { return [] }
        let matches  = regex.matches(in: self, options: [], range: NSMakeRange(0, self.count))
        return matches.map { match in
            return String(self[Range(match.range, in: self)!])
        }
    }
}
