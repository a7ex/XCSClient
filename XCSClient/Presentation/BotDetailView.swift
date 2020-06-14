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
    @EnvironmentObject var connection: XCSConnector
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(bot.name)
                    .font(.headline)
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
