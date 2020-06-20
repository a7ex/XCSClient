//
//  LoginView.swift
//  XCSClient
//
//  Created by Alex da Franca on 12.06.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import SwiftUI

struct LoginView: View {
    let myWindow: NSWindow?
    
    @State private var xcodeServerData = XcodeServer.none
    @State private var sshAddress = "10.175.31.236"
    @State private var sshUser = "adafranca"
    
    @State private var hasError = false
    @State private var errorMessage = ""
    @State private var activityShowing = false
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Text("Xcode server")
                        .frame(minWidth: 200, alignment: .trailing)
                    MenuButton(label: Text(xcodeServerData.name)) {
                        Button(action: { self.xcodeServerData = .miniAgent01 }) {
                            Text(XcodeServer.miniAgent01.name)
                        }
                        Button(action: { self.xcodeServerData = .miniAgent02 }) {
                            Text(XcodeServer.miniAgent02.name)
                        }
                        Button(action: { self.xcodeServerData = .miniAgent03 }) {
                            Text(XcodeServer.miniAgent03.name)
                        }
                    }
                }
                LabeledTextInput(label: "SSH Jumphost Address", content: $sshAddress)
                LabeledTextInput(label: "SSH Username", content: $sshUser)
                
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
    
    private func loadBots() {
        let connector = XCSConnector(
            server: Server(
                xcodeServerAddress: xcodeServerData.ipAddress,
                sshEndpoint: "\(sshUser)@\(sshAddress)"
            ),
            name: xcodeServerData.name
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
        let connector = XCSConnector(server: Server(xcodeServerAddress: XcodeServer.miniAgent03.ipAddress, sshEndpoint: "adafranca@10.175.31.236"), name: "Mac Mini 01")
        return LoginView(myWindow: nil).environmentObject(connector)
    }
}
