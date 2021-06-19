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
    
    private let viewModel = ServerOutlineListViewModel()
    
    var body: some View {
        List(xcodeServersArray, id: \.id, children: \.children) { item in
            HStack {
                if let cell = item as? ShowMoreLessCellModel {
                    ShowMoreLessButton(
                        showMoreDisabled: cell.isShowMoreDisabled,
                        showLessDisabled: cell.isShowLessDisabled,
                        showMoreTapped: {
                            viewModel.changeNumberOfVisibleIntegrations(of: cell, change: 5)
                        },
                        showLessTapped: {
                            viewModel.resetNumberOfVisibleIntegrations(of: cell)
                        },
                        showAllTapped: {
                            viewModel.showAllIntegrations(of: cell)
                        }
                    )
                } else if let cell = item as? ShowLessCellModel {
                    ShowLessButton(
                        showLessTapped: {
                            viewModel.resetNumberOfVisibleIntegrations(of: cell)
                        }
                    )
                } else {
                    if item.statusColor == .clear {
                        AnimatingIcon()
                            .onAppear {
                                viewModel.refreshIntegrationStatus(of: item)
                            }
                    } else {
                        Image(systemName: item.systemIconName)
                            .foregroundColor(item.statusColor)
                    }
                    NavigationLink(destination: item.destination) {
                        HStack {
                            Text(item.title)
                            if let bot = item as? CDBot {
                                Spacer()
                                if bot.visibleItems > 2 {
                                    Button(action: { viewModel.resetNumberOfVisibleIntegrations(of: bot)
                                    }) {
                                        Image(systemName: "arrow.up")
                                            .frame(minWidth: 20)
                                    }
                                    .buttonStyle(LinkButtonStyle())
                                }
                                if bot.updateInProgress {
                                    ProgressView()
                                        .frame(width: 20, height: 10)
                                        .progressViewStyle(CircularProgressViewStyle())
                                        .scaleEffect(0.5, anchor: .center)
                                } else {
                                    bot.firstIntegrationStatus
                                }
                            }
                        }
                    }
                }
            }
        }
        .listStyle(.sidebar)
        .onAppear {
            DataSyncWorker.updateData(in: viewContext)
        }
        .onReceive(timer) { _ in
            DataSyncWorker.updateData(in: viewContext)
        }
    }
}

struct ServerOutlineList_Previews: PreviewProvider {
    static var previews: some View {
        ServerOutlineList()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext) 
    }
}
