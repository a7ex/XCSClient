//
//  BotDetailView.swift
//  XCSClient
//
//  Created by Alex da Franca on 12.06.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import SwiftUI

struct BotDetailView: View {
    let bot: BotVM
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
                Text(bot.name)
                    .font(.headline)
                    Spacer()
                    MenuButton(label: Text("⚙️").font(.headline)) {
                        Button(action: { self.integrate(self.bot) }) {
                            Text("Start Integration")
                        }
                        Button(action: { self.duplicate(self.bot) }) {
                            Text("Duplicate Bot")
                        }
                        Button(action: { self.export(self.bot) }) {
                            Text("Export settings…")
                        }
                        Button(action: { self.apply(to: self.bot) }) {
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
                Divider()
                VStack(alignment: .leading, spacing: 8) {
                    Group {
                        LabeledStringValue(label: "ID", value: bot.id)
                        LabeledStringValue(label: "TinyId", value: bot.tinyID)
                        LabeledStringValue(label: "Integration Counter", value: String(bot.integrationCounter))
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
                        if bot.botModel.configuration?.scheduleType == ScheduleType.periodically {
                            LabeledStringValue(label: "Periodic Schedule Interval", value: bot.periodicScheduleInterval)
                            if bot.botModel.configuration?.periodicScheduleInterval == .weekly {
                                LabeledStringValue(label: "Weekly Schedule Day", value: bot.weeklyScheduleDay)
                                LabeledStringValue(label: "Hour", value: bot.integrationTimeSchedule)
                            } else if bot.botModel.configuration?.periodicScheduleInterval == .daily {
                                LabeledStringValue(label: "Hour", value: bot.integrationTimeSchedule)
                            } else if bot.botModel.configuration?.periodicScheduleInterval == .hourly {
                                LabeledStringValue(label: "Minute", value: bot.integrationMinuteSchedule)
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
                            Toggle("Archive", isOn: $botEditableData.performsArchiveAction)
                            Toggle("Integrate on Upgrade", isOn: $botEditableData.performsUpgradeIntegration)
                            }
                            .padding(.trailing)
                        }
                        Divider()
                        HStack {
                            Toggle("Disable App Thinning", isOn: $botEditableData.disableAppThinning)
                            Toggle("Exports Product From Archive", isOn: $botEditableData.exportsProductFromArchive)
                        }
                    }
                }
                Divider()
                Button(action: { self.uploadChanged(self.bot) }) {
                    ButtonLabel(text: "Save changes")
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
                      primaryButton: .default(Text("Delete")) { self.delete(self.bot) },
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
    
    private func integrate(_ bot: BotVM) {
        connector.integrate(bot.botModel) { (result) in
            switch result {
                case .success(let integration):
                    self.errorMessage = "Successfully startet integration with ID: \(integration.tinyID ?? integration.id)"
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
            }
            self.hasError = true
        }
    }
    
    private func uploadChanged(_ bot: BotVM) {
        let newBot = bot.botModel.applying(botEditableData)
        applyChanges(newBot.asBodyParamater, to: bot)
    }
    
    private func delete(_ bot: BotVM) {
        connector.delete(bot.botModel) { (result) in
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
    
    private func duplicate(_ bot: BotVM) {
        connector.duplicate(bot.botModel) { (result) in
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
    
    private func export(_ bot: BotVM) {
        connector.exportBotSettings(of: bot.botModel) { (result) in
            switch result {
                case .success(let json):
                    self.openBotSettingsEditorWindow(with: String(decoding: json, as: UTF8.self), for: bot)
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.hasError = true
            }
        }
    }
    
    private func apply(to bot: BotVM) {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.allowedFileTypes = ["json"]
        let result = panel.runModal()
        guard result == .OK,
            let url = panel.url else {
                return
        }
        connector.applySettings(at: url, fileName: "\(bot.tinyID).json", toBot: bot.botModel) { (result) in
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
    
    private func applyChanges(_ newJSON: String, to bot: BotVM) {
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
            
            connector.applySettings(at: tempFileUrl, fileName: "\(bot.tinyID).json", toBot: bot.botModel) { (result) in
                
                withAnimation {
                    self.activityShowing = false
                }
                
                switch result {
                case .success(let bot):
                    NotificationCenter.default.post(name: NSNotification.Name("RefreshBotList"), object: nil)
                    self.errorMessage = "Successfully modified bot: \"\(bot.name)\""
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
    
    private func openBotSettingsEditorWindow(with textContent: String, for bot: BotVM) {
        openTextEditorWindow(with: textContent, title: "\(bot.tinyID).json") { newText in
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
        var bot = Bot(id: UUID().uuidString, name: "Project_Foo_Fabric_DeviceCloud", tinyID: "3")
        var configuration = BotConfiguration()
        configuration.performsArchiveAction = true
        bot.configuration = configuration
        bot.integrationCounter = 12
        return BotDetailView(bot: BotVM(bot: bot)).environmentObject(XCSConnector.previewServerConnector)
    }
}
