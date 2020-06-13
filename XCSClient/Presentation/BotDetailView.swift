//
//  BotDetailView.swift
//  XCSClient
//
//  Created by Alex da Franca on 12.06.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import SwiftUI

struct BotDetailView: View {
    let bot: Bot
    let integrations: [Integration]
    @EnvironmentObject var connection: XCSConnector
    
    var body: some View {
        VStack {
            Text(bot.name)
                .font(.subheadline)
                .padding()
            
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top) {
                    InfoLabel(content: "id")
                    Text(bot.id ?? "- missing -")
                }
                HStack(alignment: .top) {
                    InfoLabel(content: "TinyId")
                    Text(bot.tinyID ?? "- missing -")
                }
                HStack(alignment: .top) {
                    InfoLabel(content: "Integration Counter")
                    Text(String(bot.integrationCounter ?? 0))
                }
                
                BooleanValue(content: "Performs Analyze Action", value: bot.configuration?.performsAnalyzeAction ?? false)
                BooleanValue(content: "Performs Test Action", value: bot.configuration?.performsTestAction ?? false)
                BooleanValue(content: "Performs Archive Action", value: bot.configuration?.performsArchiveAction ?? false)
                BooleanValue(content: "Performs Upgrade Integration", value: bot.configuration?.performsUpgradeIntegration ?? false)
                
                Spacer()
                InfoLabel(content: "Integrations:")
                IntegrationListView(integrations: integrations)
                    .frame(minWidth: 240, alignment: .leading)
                    .background(Color.white)
            }
            .frame(minWidth: 300)
        }
    }
}

struct InfoLabel: View {
    let content: String
    var body: some View {
        Text(content)
            .fontWeight(.bold)
    }
}

struct BotDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let bot = Bot(id: UUID().uuidString, name: "DHLPaket_GIT_Fabric_DeviceCloud", tinyID: "3")
        return BotDetailView(bot: bot, integrations: [Integration]())
    }
}

struct BooleanValue: View {
    let content: String
    let value: Bool
    
    var body: some View {
        HStack(alignment: .top) {
            InfoLabel(content: content)
            Text(value ? "✅": "❌")
        }
    }
}
