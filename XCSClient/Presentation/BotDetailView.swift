//
//  BotDetailView.swift
//  XCSClient
//
//  Created by Alex da Franca on 12.06.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import SwiftUI

struct BotDetailView: View {
    let bot: BotViewModel
    let changeClosure: (Bot) -> Void
    
    @EnvironmentObject var connector: XCSConnector
    
    @State private var hasError = false
    @State private var errorMessage = ""
    @State private var deleteConfirm = false
    @State private var activityShowing = false
    
    @ObservedObject private var botEditableData = BotEditorData()
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Spacer()
                    Text(bot.nameString)
                    .font(.headline)
                    Text("- \(bot.tinyIDString) (\(bot.integrationCounterInt))")
                    Spacer()
                    MenuButton(label: Text("⚙️").font(.headline)) {
                        Button(action: { self.integrate() }) {
                            Text("Start Integration")
                        }
                        Button(action: { self.duplicate() }) {
                            Text("Duplicate Bot")
                        }
                        Button(action: { self.export() }) {
                            Text("Export settings…")
                        }
                        Button(action: { self.applySettings() }) {
                            Text("Apply settings…")
                        }
                        Button(action: { self.deleteConfirm = true }) {
                            Text("Delete Bot")
                        }
                        .foregroundColor(.red)
                    }
                    .menuButtonStyle(BorderlessButtonMenuButtonStyle())
                    .frame(width: 20)
                }
                HStack {
                    Spacer()
                    Text(bot.idString)
                        .font(.footnote)
                        .contextMenu {
                            Button(action: {
                                let pb = NSPasteboard.general
                                pb.declareTypes([.string], owner: nil)
                                pb.setString(bot.idString, forType: .string)
                            }) {
                                Text("Copy")
                            }
                        }
                    Spacer()
                }
                Divider()
                VStack(alignment: .leading, spacing: 8) {
                    Group {
                        LabeledTextInput(label: "Name", content: $botEditableData.name)
                        LabeledTextInput(label: "Additional Build Arguments", content: $botEditableData.additionalBuildArguments)
                        LabeledTextInput(label: "Scheme", content: $botEditableData.scheme)
                        LabeledTextInput(label: "Build Configuration", content: $botEditableData.buildConfig)
                        LabeledTextInput(label: "Branch", content: $botEditableData.branch)
                    }
                    Group {
                        HStack(alignment: .top) {
                            InfoLabel(content: "ScheduleType")
                                .frame(minWidth: 100, maxWidth: 160, alignment: .leading)
                                .padding([.bottom], 4)
                            MenuButton(label: Text(botEditableData.scheduleType)) {
                                ForEach(ScheduleType.allStringValues, id: \.self) { scheduleType in
                                    Button(action: { self.botEditableData.scheduleType = scheduleType }) {
                                            Text(scheduleType)
                                        }
                                }
                            }
                        }
                        if bot.scheduleType == ScheduleType.periodically {
                            if bot.periodicScheduleInterval == .weekly {
                                LabeledStringValue(
                                    label: "Periodic Schedule",
                                    value: "Every \(bot.weeklyScheduleDay) at \(bot.integrationTimeSchedule):00"
                                )
                            } else if bot.periodicScheduleInterval == .daily {
                                LabeledStringValue(
                                    label: "Periodic Schedule",
                                    value: "\(bot.periodicScheduleIntervalString) at \(bot.integrationTimeSchedule):00"
                                )
                            } else if bot.periodicScheduleInterval == .hourly {
                                LabeledStringValue(
                                    label: "Periodic Schedule",
                                    value: "Every hour at minute \(bot.integrationMinuteSchedule)"
                                )
                            }
                        }
                    }
                    if !bot.buildEnvironmentVariables.isEmpty {
                        HStack(alignment: .top) {
                            InfoLabel(content: "Environment vars")
                                .frame(minWidth: 100, maxWidth: 160, alignment: .leading)
                                .padding([.bottom], 4)
                            VStack(alignment: .leading, spacing: 4) {
                                ForEach(self.botEditableData.environmentVariables) { pair in
                                    Text("\(pair.id) = \(pair.value)")
                                }
                            }
                        }
                    }
                    if !botEditableData.triggerScripts.isEmpty {
                        HStack {
                            InfoLabel(content: "Triggers")
                                .frame(minWidth: 100, maxWidth: 160, alignment: .leading)
                                .padding([.bottom], 4)
                            ForEach(botEditableData.triggerScripts, id: \.name) { triggerScript in
                                Button(action: { self.editTrigger(triggerScript) }) {
                                    Text("\(triggerScript.name) {…}")
                                }
                            }
                        }
                    }
                    Group {
                        Divider()
                        HStack {
                            Group {
                            Toggle("Analyze", isOn: $botEditableData.performsAnalyzeAction)
                            Toggle("Test", isOn: $botEditableData.performsTestAction)
                            Toggle("Integrate on Upgrade", isOn: $botEditableData.performsUpgradeIntegration)
                            }
                            .padding(.trailing)
                        }
                        Divider()
                        HStack {
                            Toggle("Archive", isOn: $botEditableData.performsArchiveAction)
                            Toggle("Disable App Thinning", isOn: $botEditableData.disableAppThinning)
                                .disabled(!botEditableData.performsArchiveAction)
                            Toggle("Exports Product From Archive", isOn: $botEditableData.exportsProductFromArchive)
                                .disabled(!botEditableData.performsArchiveAction)
                        }
                        if botEditableData.exportsProductFromArchive {
                            Divider()
                            HStack {
                                InfoLabel(content: "Archive Options")
                                    .frame(minWidth: 100, maxWidth: 160, alignment: .leading)
                                    .padding([.bottom], 4)
                                Button(action: { self.selectExportOptions() }) {
                                    Text("\(bot.archiveExportOptionsName) {…}")
                                }
                            }
                            if !bot.archiveExportOptionsName.isEmpty {
                                LabeledStringValue(label: "Provisioning Profile", value: "\(bot.archiveExportOptionsProvisioningProfiles)")
                            }
                        }
                    }
                }
                Divider()
                Button(action: { self.uploadChanges() }) {
                    ButtonLabel(text: "Save changes")
                }
                Button(action: { self.integrate() }) {
                    ButtonLabel(text: "Start Integration")
                }
                Spacer()
            }
            .padding()
            .alert(isPresented: $hasError) {
                Alert(title: Text(errorMessage))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear {
                self.botEditableData.setup(with: self.bot)
            }
            .alert(isPresented: $deleteConfirm) {
                Alert(title: Text("Deleting a bot can not be undone! All archived data for the bot will be erased."),
                      primaryButton: .default(Text("Delete")) { self.delete() },
                      secondaryButton: .cancel()
                )
            }
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
    
    private func selectExportOptions() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.allowedFileTypes = ["plist"]
        let result = panel.runModal()
        guard result == .OK,
            let url = panel.url,
            let data = try? Data(contentsOf: url) else {
                return
        }
        let decoder = PropertyListDecoder()
        if let exportOptions = try? decoder.decode(IPAExportOptions.self, from: data) {
            let expOptions = ArchiveExportOptions(name: url.lastPathComponent, createdAt: Date(), exportOptions: exportOptions)
            botEditableData.exportOptions = expOptions
        }
    }
    
    private func editTrigger(_ triggerScript: TriggerScript) {
        openTextEditorWindow(with: triggerScript.script, title: triggerScript.name) { newText in
            guard let newTriggerScript = TriggerScript(name: triggerScript.name, script: newText) else {
                return
            }
            self.botEditableData.triggerScripts = self.botEditableData.triggerScripts.map { script in
                if script.name == newTriggerScript.name {
                    return newTriggerScript
                } else {
                    return script
                }
            }
        }
    }
    
    private func integrate() {
        connector.integrate(bot.idString) { (result) in
            switch result {
                case .success(let integration):
                    self.errorMessage = "Successfully startet integration with ID: \(integration.tinyID ?? integration.id)"
                    if let bot = bot as? CDBot {
                        IntegrationUpdateWorker.add(bot)
                    }
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
            }
            self.hasError = true
        }
    }
    
    private func uploadChanges() {
        let newBot = bot.applying(botEditableData)
        applyChanges(newBot.asBodyParamater, to: bot)
    }
    
    private func delete() {
        connector.deleteBot(with: bot.idString, revId: bot.revIdString) { (result) in
            switch result {
                case .success(let success):
                    NotificationCenter.default.post(name: NSNotification.Name("RefreshBotList"), object: nil)
                    self.errorMessage = success ? "Bot successfully deleted": "Failed to delete Bot"
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
            }
            self.hasError = true
        }
    }
    
    private func duplicate() {
        connector.duplicateBot(with: bot.idString) { (result) in
            switch result {
                case .success(let bot):
                    NotificationCenter.default.post(name: NSNotification.Name("RefreshBotList"), object: nil)
                    self.errorMessage = "Successfully duplicated bot: \"\(bot.name)\""
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
            }
            self.hasError = true
        }
    }
    
    private func export() {
        openBotSettingsEditorWindow(with: bot.exportSettings, for: bot)
    }
    
    private func applySettings() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.allowedFileTypes = ["json"]
        let result = panel.runModal()
        guard result == .OK,
            let url = panel.url else {
                return
        }
        connector.applySettings(at: url, fileName: "\(bot.tinyIDString).json", toBot: bot.idString) { (result) in
            switch result {
                case .success(let bot):
                    NotificationCenter.default.post(name: NSNotification.Name("RefreshBotList"), object: nil)
                    self.errorMessage = "Successfully modified bot: \"\(bot.name)\""
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
            }
            self.hasError = true
        }
    }
    
    private func applyChanges(_ newJSON: String, to bot: BotViewModel) {
        let fileManager = FileManager.default
        guard let cachesDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            return
        }
        let tempFileUrl = cachesDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("json")
        do {
            try Data(newJSON.utf8).write(to: tempFileUrl)
            
            withAnimation {
                self.activityShowing = true
            }
            
            connector.applySettings(at: tempFileUrl, fileName: "\(bot.tinyIDString).json", toBot: bot.idString) { (result) in
                
                withAnimation {
                    self.activityShowing = false
                }
                
                switch result {
                case .success(let bot):
                    NotificationCenter.default.post(name: NSNotification.Name("RefreshBotList"), object: nil)
                    self.errorMessage = "Successfully modified bot: \"\(bot.name)\""
                    self.changeClosure(bot)
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
                try? FileManager.default.removeItem(at: tempFileUrl)
                self.hasError = true
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func openBotSettingsEditorWindow(with textContent: String, for bot: BotViewModel) {
        openTextEditorWindow(with: textContent, title: "\(bot.tinyIDString).json") { newText in
            self.applyChanges(newText, to: bot)
        }
    }
    
    private func openTextEditorWindow(with textContent: String, title: String, completion: @escaping (String) -> Void) {
        let sb = NSStoryboard(name: "Main", bundle: nil)
        if let windowController = sb.instantiateController(withIdentifier: "TextEditorWindow") as? NSWindowController,
            let controller = windowController.contentViewController as? SimpleTextViewController {
            controller.stringContent = textContent
            controller.editableText = true
            controller.onUploadChanges(completion: completion)
            windowController.window?.title = title
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

struct BotDetailView_Previews: PreviewProvider {
    
    static var previews: some View {
        let moc = PersistenceController.preview.container.viewContext
        let request: NSFetchRequest<CDBot> = CDBot.fetchRequest()
        let obj = (try? moc.fetch(request).first)!
        
        return BotDetailView(bot: obj, changeClosure: { _ in }).environmentObject(XCSConnector.previewServerConnector)
    }
}
