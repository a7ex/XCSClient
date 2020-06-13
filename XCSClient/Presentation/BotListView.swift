//
//  BotListView.swift
//  XCSApiClient
//
//  Created by Alex da Franca on 06.06.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import SwiftUI

struct IntegrationsData {
    let botId: String
    let integrations: [Integration]
}

protocol ListTitleProviding {
    var title: String { get }
    var isExpandable: Bool { get }
    var isExpanded: Bool { get }
}

struct BotListViewModel: ListTitleProviding {
    let bot: Bot
    let isExpandable = true
    let isExpanded: Bool
    
    var title: String {
        return bot.name
    }
}

struct IntegrationListViewModel: ListTitleProviding {
    let integration: Integration
    let isExpandable = false
    let isExpanded = false
    
    var title: String {
        return integration.tinyID ?? UUID().uuidString
    }
}

struct BotListView: View {
    let myWindow: NSWindow?
    let bots: [Bot]
    @EnvironmentObject var connector: XCSConnector
    @State var botIntegrations = [IntegrationsData]()
    @State var viewModels = [ListTitleProviding]()
    
    var body: some View {
        NavigationView {
            List(bots, id: \.tinyID) { bot in
                VStack(alignment: .leading) {
                    HStack {
                        Button(action: {
                            self.toggleExpandedState(of: bot.id ?? UUID().uuidString)
                        }) {
                            Text("▼")
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        .rotationEffect(Angle(degrees: (self.botIntegrations.first(where: { $0.botId == bot.id }) != nil) ? 0: -90))
                        
                        NavigationLink(destination: BotDetailView(bot: bot, integrations: self.botIntegrations.first(where: { $0.botId == bot.id})?.integrations ?? [Integration]())) {
                            Text(bot.name)
                        }
                        .contextMenu {
                            Button(action: { self.delete(bot) }) {
                                Text("Delete Bot")
                            }
                            Button(action: { self.duplicate(bot) }) {
                                Text("Duplicate Bot")
                            }
                            Button(action: { self.exportSettings(of: bot) }) {
                                Text("Export settings…")
                            }
                            Button(action: { self.applySettings(to: bot) }) {
                                Text("Apply settings…")
                            }
                        }
                    }
                    Section {
                        ForEach(self.botIntegrations.first(where: { $0.botId == bot.id})?.integrations ?? [Integration](), id: \.id) { thisInt in
                            NavigationLink(destination: IntegrationDetailView(integration: thisInt)) {
                                Text("\(thisInt.tinyID ?? thisInt.id)")
                                    .foregroundColor(.black)
                                    .padding(.leading, 24)
                                    .background(Color.white)
                            }
                        }
                    }
                }
            }
            .listStyle(SidebarListStyle())
            .frame(minWidth: 200, minHeight: 200)
        }
        .navigationViewStyle(DoubleColumnNavigationViewStyle())
    }
    
    private func toggleExpandedState(of botId: String) {
        if botIntegrations.first(where: { $0.botId == botId }) != nil {
            self.botIntegrations = self.botIntegrations.filter { $0.botId != botId }
        } else {
            connector.getIntegrationsList(for: botId, last: 3) { (result) in
                if case let .success(integrations) = result {
                    self.botIntegrations = self.botIntegrations + [IntegrationsData(botId: botId, integrations: integrations)]
                }
            }
        }
    }
    
    private func delete(_ bot: Bot) {
        
    }
    
    private func duplicate(_ bot: Bot) {
        
    }
    
    private func exportSettings(of bot: Bot) {
        
    }
    
    private func applySettings(to bot: Bot) {
        
    }
}

struct BotList_Previews: PreviewProvider {
    static var previews: some View {
        BotListView(myWindow: nil, bots: [
            Bot(id: UUID().uuidString, name: "DHLPaket_GIT_Testflight", tinyID: "1"),
            Bot(id: UUID().uuidString, name: "DHLPaket_GIT_Testflight_Beta", tinyID: "2"),
            Bot(id: UUID().uuidString, name: "DHLPaket_GIT_Fabric_DeviceCloud", tinyID: "3"),
            Bot(id: UUID().uuidString, name: "LPS (Mock) Bot", tinyID: "4"),
            Bot(id: UUID().uuidString, name: "XCS DHL Paket Dev Unit-Tests", tinyID: "5")
        ])
    }
}
