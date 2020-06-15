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
        viewModel.items = bots.map { BotListItemVM(bot: $0, isExpanded: false) }
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                HStack {
                    Text("Bots")
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
                List(viewModel.items, id: \.id) { item in
                    VStack(alignment: .leading) {
                        HStack {
                            if item.isExpandable {
                                Button(action: {
                                    self.toggleExpandedState(of: item.id)
                                }) {
                                    Text("▼")
                                }
                                .buttonStyle(BorderlessButtonStyle())
                                .rotationEffect(Angle(degrees: item.isExpanded ? 0: -90))
                            }
                            NavigationLink(destination: item.destination) {
                                Text(item.title)
                                    .padding(.leading, item.isExpandable ? 0: 30)
                            }
                        }
                    }
                }
                .listStyle(SidebarListStyle())
            }
            .frame(minWidth: 200, maxWidth: .infinity, maxHeight: .infinity)
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
                    self.viewModel.items = bots
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
            viewModel.removeIntegrations(of: botId)
        } else {
            viewModel.addIntegrations(for: botId, integrations: [loadingPlaceholder])
            connector.getIntegrationsList(for: botId, last: 10) { (result) in
                if case let .success(integrations) = result {
                    self.viewModel.addIntegrations(for: botId, integrations: integrations.map { IntegrationVM(integration: $0) })
                }
            }
        }
    }
    
    private var loadingPlaceholder: IntegrationVM {
        let integration = Integration(id: "", rev: nil, assets: nil, bot: nil, buildResultSummary: nil, buildServiceFingerprint: nil, ccPercentage: nil, ccPercentageDelta: nil, currentStep: nil, docType: nil, duration: nil, endedTime: nil, number: nil, queuedDate: nil, result: nil, startedTime: nil, testedDevices: nil, tinyID: "Loading integrations…")
        return IntegrationVM(integration: integration)
    }
    
    class BotlistWindowDelegate: NSObject, NSWindowDelegate {
        func windowWillClose(_ notification: Notification) {
            NSWindow.login.makeKeyAndOrderFront(nil)
        }
    }
}

struct BotList_Previews: PreviewProvider {
    static var previews: some View {
        BotListView(window: nil, bots: [
            Bot(id: UUID().uuidString, name: "DHLPaket_GIT_Testflight", tinyID: "1"),
            Bot(id: UUID().uuidString, name: "DHLPaket_GIT_Testflight_Beta", tinyID: "2"),
            Bot(id: UUID().uuidString, name: "DHLPaket_GIT_Fabric_DeviceCloud", tinyID: "3"),
            Bot(id: UUID().uuidString, name: "LPS (Mock) Bot", tinyID: "4"),
            Bot(id: UUID().uuidString, name: "XCS DHL Paket Dev Unit-Tests", tinyID: "5")
            ].map { BotVM(bot: $0) })
    }
}
