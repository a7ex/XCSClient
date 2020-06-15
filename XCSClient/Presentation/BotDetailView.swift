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
                    if !bot.additionalBuildArguments.isEmpty {
                    LabeledStringValue(label: "Additional Build Arguments", value: bot.additionalBuildArguments)
                    }
                    if !bot.schemeName.isEmpty {
                    LabeledStringValue(label: "schemeName", value: bot.schemeName)
                    }
                    if !bot.buildConfiguration.isEmpty {
                    LabeledStringValue(label: "buildConfiguration", value: bot.buildConfiguration)
                    }
                    LabeledStringValue(label: "sourceControlBranch", value: bot.sourceControlBranch)
                }
                Group {
                    LabeledBooleanValue(label: "Performs Analyze Action", value: bot.performsAnalyzeAction)
                    LabeledBooleanValue(label: "Performs Test Action", value: bot.performsTestAction)
                    LabeledBooleanValue(label: "Performs Archive Action", value: bot.performsArchiveAction)
                    LabeledBooleanValue(label: "Performs Upgrade Integration", value: bot.performsUpgradeIntegration)
                }
                Group {
                    LabeledBooleanValue(label: "Disable App Thinning", value: bot.disableAppThinning)
                    LabeledBooleanValue(label: "Exports Product Rrom Archive", value: bot.exportsProductFromArchive)
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
                    Alert(title: Text("Deleting a bot can not be undone! All archived data for the bot will be erased."), primaryButton: .default(Text("Delete")) {
                        self.delete(self.bot)
                        }, secondaryButton: .cancel())
                }
            }
            Spacer()
        }
        .padding()
        .alert(isPresented: $hasError) {
            Alert(title: Text(errorMessage))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                    let panel = NSSavePanel()
                    panel.nameFieldStringValue = "\(bot.tinyID).json"
                    let result = panel.runModal()
                    guard result == .OK,
                        let url = panel.url else {
                            return
                    }
                    do {
                        try json.write(to: url)
                    } catch {
                        self.errorMessage = error.localizedDescription
                        self.hasError = true
                }
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
        return BotDetailView(bot: BotVM(bot: bot))
    }
}
