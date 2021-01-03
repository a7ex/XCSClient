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
            BotDetailView(bot: bot, changeClosure: self.saveContext)
        } else {
            Text("No data")
        }
    }
    
    private func saveContext(_ codableBot: Bot) {
        bot?.update(with: codableBot)
        
        // in order to update the list,
        // we just make a dummy change to our server
        // since the list is observing the servers it will reload
        bot?.server?.name = bot?.server?.name
        
        do {
            try self.viewContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
}

struct CDBotView_Previews: PreviewProvider {
    static var previews: some View {
        CDBotView(botID: "123")
    }
}
