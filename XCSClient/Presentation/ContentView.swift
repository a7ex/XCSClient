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
                self.showWindow()
            }) {
                Text("Login and load bots")
            }
        }
        .padding()
    }
    
    func showWindow() {
        var windowRef:NSWindow
        windowRef = NSWindow(
        contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
        styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
        backing: .buffered, defer: false)
        let botlist = BotList(myWindow: windowRef, server: Server(xcodeServerAddress: xcsServerAddress, sshEndpoint: "\(sshUser)@\(sshAddress)"))
        windowRef.contentView = NSHostingView(rootView: botlist)
        windowRef.makeKeyAndOrderFront(nil)
        myWindow?.close()
    }
    
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(myWindow: nil)
    }
}
