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
    @State private var ipaPath = "loading"
    @State private var machineName = ""
    @State private var revisionInfo = RevisionInfo(author: "", date: "", comment: "")
    
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
                    RevisionInfoView(revisionInfo: revisionInfo)
                }
                Divider()
                IntegrationResultsIconView(integration: integration)
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
            loadCommitData()
            if integration.archive.size > 0 {
                findIpa()
            }
        }
        .alert(isPresented: $hasError) {
            Alert(title: Text(errorMessage))
        }
    }
    
    private func loadCommitData() {
        let revInfo = integration.revisionInformation
        if revInfo.isEmpty {
            integration.loadCommitData() { rInfo in
                guard let rInfo = rInfo else {
                    return
                }
                revisionInfo = rInfo
            }
        } else {
            revisionInfo = RevisionInfo(
                author: revInfo.author,
                date: revInfo.date,
                comment: revInfo.comment
            )
        }
    }
    
    private func export(_ integration: IntegrationViewModel) {
        guard isServerReachable else {
            errorMessage = "No connection to server."
            hasError = true
            return
        }
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
    
    private func findIpa() {
        guard isServerReachable else {
            errorMessage = "No connection to server."
            hasError = true
            return
        }
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
        guard isServerReachable else {
            errorMessage = "No connection to server."
            hasError = true
            return
        }
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
        guard isServerReachable else {
            errorMessage = "No connection to server."
            hasError = true
            return
        }
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
        guard isServerReachable else {
            errorMessage = "No connection to server."
            hasError = true
            return
        }
        guard !integrationId.isEmpty else {
            return
        }
        withAnimation {
            activityShowing = true
        }
        connector.cancelIntegration(integrationId) { (result) in
            withAnimation {
                activityShowing = false
            }
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
    
    private var isServerReachable: Bool {
        guard let server = (integration as? CDIntegration)?.bot?.server else {
            return false
        }
        return server.reachability == Int16(ServerReachabilty.reachable.rawValue)
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
