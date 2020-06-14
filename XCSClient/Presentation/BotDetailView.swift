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
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack {
                    Text(bot.name)
                        .font(.headline)
                    Spacer()
                    MenuButton(label: Text("⚙️")) {
                        Button(action: { self.integrate(self.bot) }) {
                            Text("Integrate")
                        }
                        Button(action: { self.delete(self.bot) }) {
                            Text("Delete Bot")
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
                    }
                    .menuButtonStyle(BorderlessPullDownMenuButtonStyle())
                    .frame(width: 30)
                    .alert(isPresented: $hasError) {
                        Alert(title: Text(errorMessage))
                    }
                }
                Divider()
                VStack(alignment: .leading, spacing: 8) {
                    LabeledStringValue(label: "ID", value: bot.id)
                    LabeledStringValue(label: "TinyId", value: bot.tinyID)
                    LabeledStringValue(label: "Integration Counter", value: String(bot.integrationCounter))
                    LabeledBooleanValue(label: "Performs Analyze Action", value: bot.performsAnalyzeAction)
                    LabeledBooleanValue(label: "Performs Test Action", value: bot.performsTestAction)
                    LabeledBooleanValue(label: "Performs Archive Action", value: bot.performsArchiveAction)
                    LabeledBooleanValue(label: "Performs Upgrade Integration", value: bot.performsUpgradeIntegration)
                }
                Spacer()
            }
            .padding()
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func integrate(_ bot: BotVM) {
        connector.integrate(bot.botModel) { (result) in
            switch result {
                case .success(let integration):
                    print("Successfully startet integration with ID: \(integration.tinyID ?? integration.id)")
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.hasError = true
            }
        }
    }
    
    private func delete(_ bot: BotVM) {
        connector.delete(bot.botModel) { (result) in
            switch result {
                case .success(let success):
                    print("Bot eletion with success: \"\(success)\"")
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.hasError = true
            }
        }
    }
    
    private func duplicate(_ bot: BotVM) {
        connector.duplicate(bot.botModel) { (result) in
            switch result {
                case .success(let bot):
                    print("Successfully duplicated bot: \"\(bot.name)\"")
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.hasError = true
            }
        }
    }
    
    private func export(_ bot: BotVM) {
        connector.exportBotSettings(of: bot.botModel) { (result) in
            switch result {
                case .success(let json):
                print(json)
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.hasError = true
            }
        }
    }
    
    private func apply(to bot: BotVM) {
        
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
