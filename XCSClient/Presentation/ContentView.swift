//
//  ContentView.swift
//  XCSClient
//
//  Created by Alex da Franca on 12.06.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    let myWindow: NSWindow?
    
    @State private var xcsServerAddress = "10.172.200.20"
    @State private var sshAddress = "10.175.31.236"
    @State private var sshUser = "adafranca"
    
    @State private var hasError = false
    @State private var errorMessage = ""
    
    var body: some View {
        VStack {
            HStack {
                Text("Xcode Server Address:")
                    .frame(minWidth: 200, alignment: .trailing)
                TextField("Enter Xcode Server Address", text: $xcsServerAddress)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            HStack {
                Text("SSH Jumphost Address:")
                    .frame(minWidth: 200, alignment: .trailing)
                TextField("Enter Jumphost Address", text: $sshAddress)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            HStack {
                Text("SSH Username:")
                    .frame(minWidth: 200, alignment: .trailing)
                TextField("Enter SSH Username", text: $sshUser)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            Button(action: {
                self.loadBots()
            }) {
                Text("Login and load bots")
            }
        }
        .frame(minWidth: 400)
        .padding()
        .alert(isPresented: $hasError) {
            Alert(title: Text(errorMessage))
        }
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
        let botlist = BotListView(myWindow: windowRef, bots: bots).environmentObject(connector)
        windowRef.contentView = NSHostingView(rootView: botlist)
        windowRef.makeKeyAndOrderFront(nil)
        myWindow?.close()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
         let connector = XCSConnector(server: Server(xcodeServerAddress: "10.172.200.20", sshEndpoint: "adafranca@10.175.31.236"))
        return ContentView(myWindow: nil).environmentObject(connector)
    }
}
