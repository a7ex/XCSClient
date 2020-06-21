//
//  BotDetailView.swift
//  XCSClient
//
//  Created by Alex da Franca on 12.06.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import SwiftUI

class FormData: ObservableObject {
    @Published var branch = ""
    @Published var scheme = ""
    @Published var buildConfig = ""
    @Published var additionalBuildArguments = ""
    @Published var name = ""
    
    func setup(with bot: BotVM) {
        branch = bot.sourceControlBranch
        scheme = bot.schemeName
        buildConfig = bot.buildConfiguration
        additionalBuildArguments = bot.additionalBuildArguments
        name = bot.name
    }
}

struct BotDetailView: View {
    let bot: BotVM
    @EnvironmentObject var connector: XCSConnector
    
    @State private var hasError = false
    @State private var errorMessage = ""
    @State private var deleteConfirm = false
    
    @ObservedObject private var formData = FormData()
    
    var body: some View {
        VStack {
            Text(bot.name)
                .font(.headline)
            Divider()
            VStack(alignment: .leading, spacing: 8) {
                Group {
                    LabeledStringValue(label: "ID", value: bot.id)
                    LabeledStringValue(label: "TinyId", value: bot.tinyID)
                    LabeledStringValue(label: "Integration Counter", value: String(bot.integrationCounter))
                    LabeledTextInputValue(label: "Name", value: $formData.name)
                    if !bot.additionalBuildArguments.isEmpty {
                        LabeledTextInputValue(label: "Additional Build Arguments", value: $formData.additionalBuildArguments)
                    }
                    if !bot.schemeName.isEmpty {
                        LabeledTextInputValue(label: "Scheme", value: $formData.scheme)
                    }
                    if !bot.buildConfiguration.isEmpty {
                        LabeledTextInputValue(label: "Build Configuration", value: $formData.buildConfig)
                    }
                    LabeledTextInputValue(label: "Branch", value: $formData.branch)
                }
                Group {
                    LabeledBooleanValue(label: "Performs Analyze Action", value: bot.performsAnalyzeAction)
                    LabeledBooleanValue(label: "Performs Test Action", value: bot.performsTestAction)
                    LabeledBooleanValue(label: "Performs Archive Action", value: bot.performsArchiveAction)
                    LabeledBooleanValue(label: "Performs Upgrade Integration", value: bot.performsUpgradeIntegration)
                }
                Group {
                    LabeledBooleanValue(label: "Disable App Thinning", value: bot.disableAppThinning)
                    LabeledBooleanValue(label: "Exports Product From Archive", value: bot.exportsProductFromArchive)
                    LabeledStringValue(label: "ScheduleType", value: bot.scheduleType)
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
            }
            Divider()
            Group {
                Button(action: { self.integrate(self.bot) }) {
                    ButtonLabel(text: "Start Integration")
                }
                Button(action: { self.duplicate(self.bot) }) {
                    ButtonLabel(text: "Duplicate Bot")
                }
                Button(action: { self.export(self.bot) }) {
                    ButtonLabel(text: "Export settings…")
                }
                Button(action: { self.apply(to: self.bot) }) {
                    ButtonLabel(text: "Apply settings…")
                }
                Button(action: { self.deleteConfirm = true }) {
                    ButtonLabel(text: "Delete Bot")
                }
                .foregroundColor(.red)
                .alert(isPresented: $deleteConfirm) {
                    Alert(title: Text("Deleting a bot can not be undone! All archived data for the bot will be erased."),
                          primaryButton: .default(Text("Delete")) { self.delete(self.bot) },
                          secondaryButton: .cancel()
                    )
                }
            }
            Spacer()
        }
        .padding()
        .alert(isPresented: $hasError) {
            Alert(title: Text(errorMessage))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            self.formData.setup(with: self.bot)
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
                    self.openTextEditorWindow(with: String(decoding: json, as: UTF8.self), windowTitle: "\(bot.tinyID).json")
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
    
    private func openTextEditorWindow(with textContent: String, windowTitle: String = "Unnamed") {
        let sb = NSStoryboard(name: "Main", bundle: nil)
        if let windowController = sb.instantiateController(withIdentifier: "TextEditorWindow") as? NSWindowController,
            let controller = windowController.contentViewController as? SimpleTextViewController {
            controller.stringContent = textContent
            controller.editableText = true
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

struct BotDetailView_Previews: PreviewProvider {
    
    static var previews: some View {
        var bot = Bot(id: UUID().uuidString, name: "DHLPaket_GIT_Fabric_DeviceCloud", tinyID: "3")
        var configuration = BotConfiguration()
        configuration.performsArchiveAction = true
        bot.configuration = configuration
        bot.integrationCounter = 12
        return BotDetailView(bot: BotVM(bot: bot)).environmentObject(XCSConnector.previewServerConnector)
    }
}
