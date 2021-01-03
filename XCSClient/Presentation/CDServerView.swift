//
//  CDServerView.swift
//  XCSClient
//
//  Created by Alex da Franca on 25.12.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import SwiftUI

struct CDServerView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    var fetchRequest: FetchRequest<CDServer>
    var server: CDServer? {
        return fetchRequest.wrappedValue.first
    }
    
    @State private var name = ""
    @State private var ipAddress = ""
    @State private var sshAddress = ""
    @State private var sshUser = ""
    @State private var netRCFilename = ""
    
    init(serverID: String) {
        fetchRequest = FetchRequest<CDServer>(
            entity: CDServer.entity(),
            sortDescriptors: [],
            predicate: NSPredicate(format: "id == %@", serverID)
        )
    }
    var body: some View {
        VStack {
            Image("Image")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: 200)
                .padding()
            LiveLabeledTextInput(label: "Server name", content: $name, onCommit:  {
                server?.name = name
                saveContext()
            })
            LiveLabeledTextInput(label: "Server IP", content: $ipAddress, onCommit:  {
                server?.ipAddress = ipAddress
                saveContext()
            })
            LiveLabeledTextInput(label: "SSH IP", content: $sshAddress, onCommit:  {
                server?.sshAddress = sshAddress
                saveContext()
            })
            LiveLabeledTextInput(label: "SSH user", content: $sshUser, onCommit:  {
                server?.sshUser = sshUser
                saveContext()
            })
            LiveLabeledTextInput(label: "NetRC file", content: $netRCFilename, onCommit:  {
                server?.netRCFilename = netRCFilename
                saveContext()
            })
            Divider()
            Button(action: reloadBots) {
                ButtonLabel(text: "Reload Bots")
            }
            Button(action: deleteServer) {
                ButtonLabel(text: "Delete")
                    .foregroundColor(.red)
            }
            Spacer()
        }
        .padding()
        .onAppear {
            name = server?.name ?? ""
            ipAddress = server?.ipAddress ?? ""
            sshAddress = server?.sshAddress ?? ""
            sshUser = server?.sshUser ?? ""
            netRCFilename = server?.netRCFilename ?? ""
        }
    }
    
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func deleteServer() {
        fetchRequest.wrappedValue.forEach { item in
            viewContext.delete(item)
        }
        saveContext()
    }
    
    private func reloadBots() {
        if let items = server?.items {
            server?.removeFromItems(items)
            saveContext()
        }
        server?.connector.getBotList { (result) in
            if case let .success(bots) = result {
                bots.forEach { (bot) in
                    if let bot = viewContext.bot(from: bot) {
                        server?.addToItems(bot)
                    }
                }
                saveContext()
            }
        }
    }
}

struct CDServerView_Previews: PreviewProvider {
    static var previews: some View {
        CDServerView(serverID: "")
    }
}
