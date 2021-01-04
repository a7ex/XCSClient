//
//  CDBotView.swift
//  XCSClient
//
//  Created by Alex da Franca on 25.12.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import SwiftUI

struct CDBotView: View {
    @Environment(\.managedObjectContext) private var viewContext
    var fetchRequest: FetchRequest<CDBot>
    
    var bot: CDBot? {
        return fetchRequest.wrappedValue.first
    }
    
    init(botID: String) {
        fetchRequest = FetchRequest<CDBot>(
            entity: CDBot.entity(),
            sortDescriptors: [],
            predicate: NSPredicate(format: "id == %@", botID)
        )
    }
    
    var body: some View {
        if let bot = bot {
            BotDetailView(bot: bot)
        } else {
            Text("No data")
        }
    }
}

struct CDBotView_Previews: PreviewProvider {
    static var previews: some View {
        CDBotView(botID: "123")
    }
}
