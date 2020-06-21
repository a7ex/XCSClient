//
//  LoginView.swift
//  XCSClient
//
//  Created by Alex da Franca on 12.06.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import SwiftUI

extension Array where Element == XcodeServer {
    var lastUsed: XcodeServer? {
        guard let name = UserDefaults.standard.object(forKey: "lastUsedXcodeServerName") as? String,
            !name.isEmpty else {
                return nil
        }
        return first { $0.name == name}
    }
}

struct LoginView: View {
    let myWindow: NSWindow?
    
    init(window: NSWindow?) {
        self.myWindow = window
        xcodeServers = UserDefaults.standard.object(forKey: "xcodeServers") as? [XcodeServer] ?? [XcodeServer]()
        if let lastUsedServer = xcodeServers.lastUsed {
            populateFields(for: lastUsedServer)
        } else if let first = xcodeServers.first {
            populateFields(for: first)
        }
    }
    
    private let xcodeServers: [XcodeServer]
    
    @State private var xcodeServerName = "Recents"
    @State private var xcodeServerAddress = ""
    @State private var sshAddress = ""
    @State private var sshUser = ""
    @State private var netRCFilename = ""
    
    @State private var hasError = false
    @State private var errorMessage = ""
    @State private var activityShowing = false
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Text("Xcode server")
                        .frame(minWidth: 200, alignment: .trailing)
                    MenuButton(label: Text(xcodeServerName)) {
                        ForEach(xcodeServers, id: \.self) { server in
                            Button(action: { self.populateFields(for: server) }) {
                                Text(server.name)
                            }
                        }
                    }
                }
                LabeledTextInput(label: "Xcode Server Address", content: $xcodeServerAddress)
                LabeledTextInput(label: "SSH Jumphost Address (optional)", content: $sshAddress)
                LabeledTextInput(label: "SSH Username (optional)", content: $sshUser)
                LabeledTextInput(label: ".netrc file (optional)", content: $netRCFilename)
                
                Button(action: { self.loadBots() }) {
                    Text("Login and load bots")
                }
                .alert(isPresented: $hasError) {
                    Alert(title: Text(errorMessage))
                }
            }
            .frame(minWidth: 400)
            .padding()
            if activityShowing {
                Color.black
                    .opacity(0.5)
                VStack {
                    ActivityIndicator()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.white)
                    Text("Logging in…")
                        .foregroundColor(.white)
                }
            }
        }
    }
    
    private func populateFields(for server: XcodeServer) {
        xcodeServerName = server.name
        xcodeServerAddress = server.ipAddress
        sshAddress = server.sshAddress
        sshUser = server.sshUser
        netRCFilename = server.netRCFilename
    }
    
    private func updateRecentXcodeServer() {
        let currentXcodeServer = XcodeServer(
            ipAddress: xcodeServerAddress,
            name: xcodeServerName,
            sshAddress: sshAddress,
            sshUser: sshUser,
            netRCFilename: netRCFilename
        )
        var newName = xcodeServerName
        if newName.isEmpty {
            newName = "Untitled Xcode Server"
        }
        while xcodeServers.first(where: { $0.name == newName }) != nil {
            newName += "-1"
        }
        UserDefaults.standard.set(xcodeServerName, forKey: newName)
        guard !xcodeServers.contains(currentXcodeServer) else {
            return
        }
        let newServers = [currentXcodeServer] + xcodeServers
        UserDefaults.standard.set(newServers, forKey: "xcodeServers")
    }
    
    private func loadBots() {
        let connector = XCSConnector(
            server: Server(
                xcodeServerAddress: xcodeServerAddress,
                sshEndpoint: "\(sshUser)@\(sshAddress)",
                netrcFilename: netRCFilename
            ),
            name: xcodeServerName
        )
        withAnimation {
            self.activityShowing = true
        }
        connector.getBotList() { result in
            withAnimation {
                self.activityShowing = false
            }
            switch result {
            case .success(let bots):
                self.updateRecentXcodeServer()
                self.openWindow(with: bots.sorted(by: { $0.name < $1.name }), connector: connector)
            case .failure(let error):
                self.errorMessage = "Error occurred: \(error.localizedDescription)"
                self.hasError = true
            }
        }
    }
    
    private func openWindow(with bots: [Bot], connector: XCSConnector) {
        let windowRef = NSWindow.botList
        let botlist = BotListView(
            window: windowRef,
            bots: bots.map { BotVM(bot: $0) }
        ).environmentObject(connector)
        windowRef.contentView = NSHostingView(rootView: botlist)
        windowRef.makeKeyAndOrderFront(nil)
        myWindow?.close()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        return LoginView(window: nil).environmentObject(XCSConnector.previewServerConnector)
    }
}
