//
//  BotListView.swift
//  XCSApiClient
//
//  Created by Alex da Franca on 06.06.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import SwiftUI

struct BotListView: View {
    let myWindow: NSWindow?
    @EnvironmentObject var connector: XCSConnector
    @ObservedObject var viewModel = BotListVM()
    @State private var botlistWindowDelegate = BotlistWindowDelegate()
    
    let refreshPublisher = NotificationCenter.default
        .publisher(for: NSNotification.Name("RefreshBotList"))
    
    init(window: NSWindow?, bots: [BotVM]) {
        myWindow = window
        myWindow?.delegate = botlistWindowDelegate
        viewModel.allItems = bots.map { BotListItemVM(bot: $0, isExpanded: false) }
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                HStack {
                    Text("Bots @ \(connector.name)")
                        .font(.headline)
                        .padding([.leading, .top])
                    Spacer()
                    Button(action: { self.reLoadBots() }) {
                        Text("↺")
                    }
                    .padding([.top, .trailing])
                    .toolTip("Reload list from server")
                }
                Divider()
                SearchBar(query: $viewModel.searchQuery)
                List(viewModel.items, id: \.id) { item in
                    VStack(alignment: .leading) {
                        HStack {
                                Button(action: {
                                    self.toggleExpandedState(of: item.id)
                                }) {
                                    Text(item.isExpandable ? "▼": "●")
                                }
                                .buttonStyle(BorderlessButtonStyle())
                                .rotationEffect(Angle(degrees: item.isExpanded ? 0: -90))
                                .foregroundColor(item.statusColor)
                                .offset(CGSize(width: item.isExpandable ? 0: 24, height: 0))
                            NavigationLink(destination: item.destination) {
                                Text(item.title)
                                    .padding(.leading, item.isExpandable ? 0: 30)
                            }
                        }
                    }
                }
                .listStyle(SidebarListStyle())
            }
            .frame(minWidth: 280, maxWidth: .infinity)
            Text("Select bot in the list of bots to see details.")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .navigationViewStyle(DoubleColumnNavigationViewStyle())
        .onReceive(refreshPublisher) { (output) in
            self.reLoadBots()
        }
    }
    
    private func reLoadBots() {
        connector.getBotList() { result in
            switch result {
                case .success(let bots):
                    self.viewModel.allItems = bots
                        .sorted(by: { $0.name < $1.name })
                        .map { BotListItemVM(bot: BotVM(bot: $0), isExpanded: false) }
                case .failure(let error):
                    print("Error occurred: \(error.localizedDescription)")
            }
        }
    }
    
    private func toggleExpandedState(of botId: String) {
        guard let bot = viewModel.items.first(where: { $0.id == botId }) else {
            return
        }
        if bot.isExpanded {
            viewModel.collapseIntegrations(of: botId)
        } else {
            viewModel.expandIntegrations(for: botId, integrations: [loadingPlaceholder(for: bot.title)])
            connector.getIntegrationsList(for: botId, last: 10) { (result) in
                switch result {
                case .success(let integrations):
                    self.viewModel.expandIntegrations(for: botId, integrations: integrations.map { IntegrationVM(integration: $0) })
                case .failure(let error):
                    print("\(error)")
                }
            }
        }
    }
    
    private func loadingPlaceholder(for botName: String) -> IntegrationVM {
        return IntegrationVM(integration: Integration(
            id: UUID().uuidString,
            tinyId: "Loading integrations…",
            bot: Bot(name: botName))
        )
    }
    
    class BotlistWindowDelegate: NSObject, NSWindowDelegate {
        func windowWillClose(_ notification: Notification) {
            NSWindow.login.makeKeyAndOrderFront(nil)
        }
    }
}

struct BotList_Previews: PreviewProvider {
    static var previews: some View {
        return BotListView(window: nil, bots: [
            Bot(id: UUID().uuidString, name: "Project_Foo_Testflight", tinyID: "1"),
            Bot(id: UUID().uuidString, name: "Project_Foo_Testflight_Beta", tinyID: "2"),
            Bot(id: UUID().uuidString, name: "Project_Foo_Fabric_DeviceCloud", tinyID: "3"),
            Bot(id: UUID().uuidString, name: "Project Bar (Mock) Bot", tinyID: "4"),
            Bot(id: UUID().uuidString, name: "XCS Project Bar Dev Unit-Tests", tinyID: "5")
            ].map { BotVM(bot: $0) }).environmentObject(XCSConnector.previewServerConnector)
    }
}
