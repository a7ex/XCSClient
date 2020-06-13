//
//  BotListView.swift
//  XCSApiClient
//
//  Created by Alex da Franca on 06.06.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import SwiftUI

struct BotListView: View {
    let myWindow: NSWindow?
    let bots: [Bot]
    
    var body: some View {
        NavigationView {
            VStack {
                ForEach(bots, id: \.tinyID) { bot in
                    NavigationLink(destination: BotDetailView(bot: bot)) {
                        Text(bot.name)
                            .frame(minWidth: 240, alignment: .trailing)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
                Spacer()
            }
            .padding(.all)
        }
    }
}

struct BotList_Previews: PreviewProvider {
    static var previews: some View {
        BotListView(myWindow: nil, bots: [
            Bot(id: UUID().uuidString, name: "DHLPaket_GIT_Testflight", tinyID: "1"),
            Bot(id: UUID().uuidString, name: "DHLPaket_GIT_Testflight_Beta", tinyID: "2"),
            Bot(id: UUID().uuidString, name: "DHLPaket_GIT_Fabric_DeviceCloud", tinyID: "3"),
            Bot(id: UUID().uuidString, name: "LPS (Mock) Bot", tinyID: "4"),
            Bot(id: UUID().uuidString, name: "XCS DHL Paket Dev Unit-Tests", tinyID: "5")
        ])
    }
}
