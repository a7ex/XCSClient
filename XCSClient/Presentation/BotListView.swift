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
        viewModel.allItems = bots.map { BotListItemVM(bot: $0, items: nil) }
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
                List(viewModel.items, id: \.id, children: \.items) { item in
                    NavigationLink(destination: item.destination) {
                        Text(item.title)
                    }
                }
                .listStyle(SidebarListStyle())
            }
            .frame(minWidth: 380, maxWidth: .infinity)
            Text("Select bot in the list of bots to see details.")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .navigationViewStyle(DoubleColumnNavigationViewStyle())
        .onReceive(refreshPublisher) { (output) in
            self.reLoadBots()
        }
        .onAppear() {
            loadAllIntegrations()
        }
    }
    
    private func reLoadBots() {
        connector.getBotList() { result in
            switch result {
                case .success(let bots):
                    self.viewModel.allItems = bots
                        .sorted(by: { $0.name < $1.name })
                        .map { BotListItemVM(bot: BotVM(bot: $0), items: nil) }
                    self.loadAllIntegrations()
                case .failure(let error):
                    print("Error occurred: \(error.localizedDescription)")
            }
        }
    }
    
    private func loadAllIntegrations() {
        for bot in viewModel.allItems {
            connector.getIntegrationsList(for: bot.id, last: 10) { (result) in
                switch result {
                case .success(let integrations):
                    self.viewModel.insertIntegrations(for: bot.id, integrations: integrations.map { IntegrationVM(integration: $0) })
                case .failure(let error):
                    print("\(error)")
                }
            }
        }
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
