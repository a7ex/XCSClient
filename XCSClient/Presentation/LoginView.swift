//
//  LoginView.swift
//  XCSClient
//
//  Created by Alex da Franca on 12.06.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import SwiftUI

struct LoginView: View {
    private struct UserDefaultsKeys {
        static let xcodeServers = "xcodeServers"
        static let lastUsedXcodeServerName = "lastUsedXcodeServerName"
    }
    let myWindow: NSWindow?
    
    init(window: NSWindow?) {
        self.myWindow = window
        if let dictionary = UserDefaults.standard.object(forKey: UserDefaultsKeys.xcodeServers) as? [[String: String]] ,
            let data = try? PropertyListSerialization.data(fromPropertyList: dictionary, format: .xml, options: 0),
            let servers = try? PropertyListDecoder().decode([XcodeServer].self, from: data) {
            xcodeServers = servers
        } else {
            xcodeServers = [XcodeServer]()
        }
    }
    
    private let xcodeServers: [XcodeServer]
    
    @State private var xcodeServerName = ""
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
                if xcodeServers.isEmpty {
                    LabeledTextInput(label: "Xcode server name", content: $xcodeServerName)
                } else {
                    HStack {
                        LabeledTextInput(label: "Xcode server name", content: $xcodeServerName)
                        MenuButton(label: Text("▼")) {
                            ForEach(xcodeServers, id: \.self) { server in
                                Button(action: { self.populateFields(for: server) }) {
                                    Text(server.name)
                                }
                            }
                        }
                        .menuButtonStyle(BorderlessButtonMenuButtonStyle())
                        .frame(width: 20)
                    }
                }
                LabeledTextInput(label: "Xcode server address", content: $xcodeServerAddress)
                LabeledTextInput(label: "SSH jumphost address (optional)", content: $sshAddress)
                LabeledTextInput(label: "SSH username (optional)", content: $sshUser)
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
            .onAppear {
                if let lastUsedServer = self.xcodeServers.lastUsed {
                    self.populateFields(for: lastUsedServer)
                } else if let first = self.xcodeServers.first {
                    self.populateFields(for: first)
                }
            }
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
        var newServerList = xcodeServers
        var newName = xcodeServerName
        if newName.isEmpty {
            newName = "Untitled Xcode Server"
        }
        UserDefaults.standard.set(newName, forKey: UserDefaultsKeys.lastUsedXcodeServerName)
        
        newServerList.removeAll(where: { $0.name == newName })
        let newServers = [currentXcodeServer] + newServerList
        guard let data = try? PropertyListEncoder().encode(newServers),
            let dictionary = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [[String: String]] else {
                return
        }
        UserDefaults.standard.set(dictionary, forKey: UserDefaultsKeys.xcodeServers)
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

extension Array where Element == XcodeServer {
    var lastUsed: XcodeServer? {
        guard let name = UserDefaults.standard.object(forKey: "lastUsedXcodeServerName") as? String,
            !name.isEmpty else {
                return nil
        }
        return first { $0.name == name}
    }
}
