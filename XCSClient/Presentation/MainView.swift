//
//  MainView.swift
//  XCSClient
//
//  Created by Alex da Franca on 24.12.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import SwiftUI

struct MainView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                HStack {
                    Text("Xcode Servers")
                        .font(.headline)
                        .padding([.leading])
                    Button(action: refreshAllServers) {
                        Image(systemName: "arrow.counterclockwise.circle")
                    }
                    .buttonStyle(LinkButtonStyle())
                    Spacer()
                    Button(action: addServer) {
                        HStack {
                            Image(systemName: "plus.circle")
                            Text("Add server")
                        }
                    }
                    .buttonStyle(LinkButtonStyle())
                    .padding([.trailing])
                }
                ServerOutlineList()
            }
            
            Text("Select bot in the list of bots to see details.")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .navigationViewStyle(DoubleColumnNavigationViewStyle())
        .onAppear {
            if numberOfServers < 1 {
                addServer()
            }
        }
    }
    
    private var numberOfServers: Int {
        let request: NSFetchRequest<CDServer> = CDServer.fetchRequest()
        let servers = try? viewContext.fetch(request)
        return servers?.count ?? 0
    }
    
    private func addServer() {
        let srv = CDServer(context: self.viewContext)
        srv.name = "Local"
        srv.ipAddress = "127.0.0.1"
        srv.id = UUID().uuidString
        do {
            try self.viewContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func refreshAllServers() {
        DataSyncWorker.updateData(in: viewContext)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
