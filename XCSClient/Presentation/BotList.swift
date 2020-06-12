//
//  BotList.swift
//  XCSApiClient
//
//  Created by Alex da Franca on 06.06.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import SwiftUI

struct BotList: View {
    let myWindow: NSWindow?
    let server: Server
    
    @State private var bots = [Bot]()
    @State private var hasError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            VStack {
                ForEach(bots, id: \.tinyID) { bot in
                    NavigationLink(destination: BotDetailView()) {
                        Text(bot.name)
                            .frame(minWidth: 240, alignment: .trailing)
                    }
                }
            }
            .padding(.all)
        }
        .onAppear {
            self.loadBots()
        }
        .alert(isPresented: $hasError) {
            Alert(title: Text(errorMessage))
        }
    }
    
    private func loadBots() {
        let rslt = server.getBotList()
        switch rslt {
        case .success(let bots):
            self.bots = bots
        case .failure(let error):
            errorMessage = "Error occurred: \(error.localizedDescription)"
            hasError = true
        }
    }
}

struct BotList_Previews: PreviewProvider {
    static var previews: some View {
        BotList(myWindow: nil, server: Server(xcodeServerAddress: "10.172.200.20", sshEndpoint: "adafranca@10.175.31.236"))
    }
}
