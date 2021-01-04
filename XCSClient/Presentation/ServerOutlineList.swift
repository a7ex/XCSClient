//
//  ServerOutlineList.swift
//  XCSClient
//
//  Created by Alex da Franca on 27.12.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import SwiftUI
import Combine

struct ServerOutlineList: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: CDServer.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \CDServer.name, ascending: true)],
        animation: .default)
    private var xcodeServers: FetchedResults<CDServer>
    private var xcodeServersArray: [OutlineElement] {
        Array(xcodeServers)
    }
    private let timer = Timer.publish(every: 300, on: .main, in: .common).autoconnect()
    
    @State private var serverIterator: IndexingIterator<FetchedResults<CDServer>>?
    @State private var botIterator: NSFastEnumerationIterator?
    
    var body: some View {
        List(xcodeServersArray, id: \.id, children: \.children) { item in
            HStack {
                if let cell = item as? ShowMoreLessCellModel {
                    ShowMoreLessButton(
                        showMoreDisabled: (cell.bot.visibleItemsCount >= (cell.bot.integrationCounterInt - 1)),
                        showLessDisabled: (cell.bot.visibleItemsCount < 3),
                        showMoreTapped: {
                            changeNumberOfVisibleIntegrations(of: cell, change: 5)
                        },
                        showLessTapped: {
                            resetNumberOfVisibleIntegrations(of: cell)
                        },
                        showAllTapped: {
                            showAllIntegrations(of: cell)
                        }
                    )
                } else if let cell = item as? ShowLessCellModel {
                    ShowLessButton(
                        showLessTapped: {
                            resetNumberOfVisibleIntegrations(of: cell)
                        }
                    )
                } else {
                    if item.statusColor == .clear {
                        AnimatingIcon()
                            .onAppear {
                                refreshIntegrationStatus(of: item)
                            }
                    } else {
                        Image(systemName: item.systemIconName)
                            .foregroundColor(item.statusColor)
                    }
                    NavigationLink(destination: item.destination) {
                        HStack {
                            Text(item.title)
                            if let bot = item as? CDBot,
                               bot.visibleItems > 2 {
                                Spacer()
                                Button(action: { resetNumberOfVisibleIntegrations(of: bot) }) {
                                    Image(systemName: "arrow.up")
                                        .frame(minWidth: 20)
                                }
                                .buttonStyle(LinkButtonStyle())
                            }
                        }
                    }
                }
            }
        }
        .listStyle(SidebarListStyle())
        .onAppear {
            DataSyncWorker.updateData(in: viewContext)
        }
        .onReceive(timer) { _ in
            DataSyncWorker.updateData(in: viewContext)
        }
    }
    
    private func refreshIntegrationStatus(of item: OutlineElement) {
        guard let bot = item as? CDBot else {
            return
        }
        IntegrationUpdateWorker.add(bot)
    }
    
    private func checkIntegrationStatus() {
        
    }
    
    private func changeNumberOfVisibleIntegrations(of model: ShowMoreLessCellModel, change: Int) {
        model.bot.visibleItemsCount += change
        saveContextAndRefresh(model.bot.server)
    }
    
    private func showAllIntegrations(of model: ShowMoreLessCellModel) {
        model.bot.visibleItemsCount = model.bot.integrationCounterInt - 1
        saveContextAndRefresh(model.bot.server)
    }
    
    private func resetNumberOfVisibleIntegrations(of model: ShowMoreLessCellModel) {
        resetNumberOfVisibleIntegrations(of: model.bot)
    }
    
    private func resetNumberOfVisibleIntegrations(of model: ShowLessCellModel) {
        resetNumberOfVisibleIntegrations(of: model.bot)
    }
    
    private func resetNumberOfVisibleIntegrations(of bot: CDBot) {
        bot.visibleItemsCount = 2
        saveContextAndRefresh(bot.server)
    }
    
    private func saveContextAndRefresh(_ server: CDServer?) {
        server?.name = server?.name
        do {
            try viewContext.save()
        } catch {
            print("ServerOutlineList error: \(error.localizedDescription)")
        }
        
    }
}

struct ServerOutlineList_Previews: PreviewProvider {
    static var previews: some View {
        ServerOutlineList()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext) 
    }
}
