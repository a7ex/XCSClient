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
                HStack(alignment: .top) {
                    InfoLabel(content: "Performs Analyze Action")
                    Text(String(bot.configuration?.performsAnalyzeAction ?? false))
                }
                HStack(alignment: .top) {
                    InfoLabel(content: "Performs Test Action")
                    Text(String(bot.configuration?.performsTestAction ?? false))
                }
                HStack(alignment: .top) {
                    InfoLabel(content: "Performs Archive Action")
                    Text(String(bot.configuration?.performsArchiveAction ?? false))
                }
                HStack(alignment: .top) {
                    InfoLabel(content: "Performs Upgrade Integration")
                    Text(String(bot.configuration?.performsUpgradeIntegration ?? false))
                }
                Spacer()
            }
            .frame(width: 400, height: 300)
        }
    }
    
    struct BotDetailView_Previews: PreviewProvider {
        static var previews: some View {
            let bot = Bot(id: UUID().uuidString, name: "DHLPaket_GIT_Fabric_DeviceCloud", tinyID: "3")
            return BotDetailView(bot: bot)
        }
    }
    
    struct InfoLabel: View {
        let content: String
        var body: some View {
            Text(content)
                .fontWeight(.bold)
        }
    }
}
