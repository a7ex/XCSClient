//
//  MainView.swift
//  XCSClient
//
//  Created by Alex da Franca on 24.12.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import SwiftUI

struct MainView: View {
    
    var body: some View {
        NavigationView {
            SideBarSplitView()
            initialDetailView
        }
        .navigationViewStyle(DoubleColumnNavigationViewStyle())
    }
    
    private var initialDetailView: some View {
        Text("Select bot in the list of bots to see details.")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
