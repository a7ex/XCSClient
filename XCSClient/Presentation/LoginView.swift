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
    
    @State private var xcsServerAddress = "10.172.200.20"
    @State private var sshAddress = "10.175.31.236"
    @State private var sshUser = "adafranca"
    
    @State private var hasError = false
    @State private var errorMessage = ""
    
    var body: some View {
        VStack {
            LabeledTextInput(label: "Xcode Server Address", content: $xcsServerAddress)
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
    }
    
    private func loadBots() {
        let connector = XCSConnector(
            server: Server(
                xcodeServerAddress: xcsServerAddress,
                sshEndpoint: "\(sshUser)@\(sshAddress)"
            )
        )
        connector.getBotList() { result in
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
        var windowRef:NSWindow
        windowRef = NSWindow(
        contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
        styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
        backing: .buffered, defer: false)
        let botlist = BotListView(window: windowRef, bots: bots.map { BotVM(bot: $0) }).environmentObject(connector)
        windowRef.contentView = NSHostingView(rootView: botlist)
        windowRef.setFrame(NSRect(x: 0, y: 0, width: 640, height: 480), display: true)
        windowRef.makeKeyAndOrderFront(nil)
        myWindow?.close()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
         let connector = XCSConnector(server: Server(xcodeServerAddress: "10.172.200.20", sshEndpoint: "adafranca@10.175.31.236"))
        return LoginView(myWindow: nil).environmentObject(connector)
    }
}
