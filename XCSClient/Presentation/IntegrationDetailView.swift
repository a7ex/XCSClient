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
    let integration: IntegrationViewModel
    
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
        if !integration.endedTimeString.isEmpty {
            timer.upstream.connect().cancel()
            return integration.durationString
        }
        let interval = startDate.timeIntervalSinceNow * -1
        let fmt = DateComponentsFormatter()
        return fmt.string(from: interval) ?? ""
    }
    
    
    var body: some View {
        ZStack {
            VStack() {
                HStack {
                    Image(systemName: "largecircle.fill.circle")
                        .foregroundColor(integration.statusColor)
                    Text("Integration \(integration.tinyIDString) (\(integration.numberInt)) - \(integration.resultString)")
                        .font(.headline)
                }
                Divider()
                Group {
                    UpdatingStatusText(currentStatus: integration.currentStepString, botId: integration.botId)
                        .font(.subheadline)
                        .padding(.bottom, 8)
                    LabeledStringValue(label: "ID", value: integration.idString)
                    LabeledStringValue(label: "Bot", value: integration.botName)
                    LabeledStringValue(label: "Date", value: integration.startDate)
                    if !integration.startTimes.isEmpty {
                        LabeledStringValue(label: "Start time", value: integration.startTimes)
                    }
                }
                Group {
                    if !integration.endedTimeString.isEmpty {
                        LabeledStringValue(label: "End time", value: integration.endedTimeString)
                    }
                    if integration.startedTime != nil {
                        LabeledStringValue(label: "Duration", value: durationInSeconds)
                            .onReceive(timer) { (timer) in
                                self.durationInSeconds = self.timeSpanFromNow(to: self.integration.startedTime)
                            }
                    }
                    if !integration.codeCoverage.isEmpty {
                        LabeledStringValue(label: "Code Coverage percentage", value: integration.codeCoverage)
                    }
                    if !integration.performanceTests.isEmpty {
                        LabeledStringValue(label: "Performance Test changes", value: integration.performanceTests)
                    }
                    if !integration.sourceControlCommitId.isEmpty {
                        LabeledStringValue(label: "Commit ID", value: integration.sourceControlCommitId)
                    }
                    if !integration.sourceControlBranch.isEmpty {
                        LabeledStringValue(label: "Branch", value: integration.sourceControlBranch)
                    }
                }
                if !revisionInfo.isEmpty {
                    Divider()
                    HStack {
                        VStack(alignment: .leading) {
                            Text(revisionInfo.author)
                            Text(revisionInfo.date)
                            Text(revisionInfo.comment)
                                .fontWeight(.bold)
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
                        Text("Passed/Failed tests: \(integration.passedTestsCount)/\(integration.testFailureCount)")
                            .font(.headline)
                        Text("(\(integration.passedTestsChange)/\(integration.testFailureChange))")
                    }
                    Spacer()
                }
                Divider()
                Group {
                    if integration.resultString == IntegrationResult.unknown.rawValue {
                        Button(action: { self.cancelIntegration(self.integration.idString) }) {
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
            self.loadCommitData()
            if integration.archive.size > 0 {
                self.findIpa()
            }
        }
    }
    
    private func export(_ integration: IntegrationViewModel) {
        guard let url = fileHelper.getSaveURLFromUser(for: "Results-\(integration.tinyIDString).tgz") else {
            return
        }
        withAnimation {
            self.activityShowing = true
        }
        connector.exportIntegrationAssets(of: integration.idString, to: url) { (result) in
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
        let assetPath = integration.sourceControlLog.path
        guard !assetPath.isEmpty else {
            return
        }
        connector.loadAsset(at: assetPath) { (result) in
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
        let assetPath = integration.buildServiceLog.path
        guard !assetPath.isEmpty else {
            return
        }
        connector.loadAsset(at: assetPath) { (result) in
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
                    integrationNumber: integration.numberInt) { path in
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
        let assetPath = asset.path
        guard !assetPath.isEmpty else {
            return
        }
        if asset.size < 500000 { // 500 KB
            withAnimation {
                self.activityShowing = true
            }
            connector.loadAsset(at: assetPath) { (result) in
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
            connector.downloadAssets(at: assetPath, to: url) { (result) in
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
     
        let moc = PersistenceController.preview.container.viewContext
        let request: NSFetchRequest<CDIntegration> = CDIntegration.fetchRequest()
        let obj = (try? moc.fetch(request).first)!
        
        return Group {
            IntegrationDetailView(integration: obj)
                .environmentObject(XCSConnector.previewServerConnector)
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
