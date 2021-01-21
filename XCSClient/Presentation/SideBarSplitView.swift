//
//  SideBarSplitView.swift
//  XCSClient
//
//  Created by Alex da Franca on 17.01.21.
//  Copyright © 2021 Farbflash. All rights reserved.
//

import SwiftUI

struct SideBarSplitView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    private let viewModel = SideBarViewModel()
    
    var body: some View {
        VStack(alignment: .leading) {
            serverOutlineListHeader
            ServerOutlineList()
        }
        .onAppear {
            viewModel.migrateServersFromPreviousVersionIfNeccessary(in: viewContext)
        }
    }
    
    private var serverOutlineListHeader: some View {
        HStack {
            Text(viewModel.masterColumnTitle)
                .font(.headline)
                .padding([.leading])
            Button(action: { viewModel.refreshAllServers(in: viewContext) }) {
                Image(systemName: "arrow.counterclockwise.circle")
            }
            .buttonStyle(LinkButtonStyle())
            Spacer()
            Button(action: {
                viewModel.addServer(in: viewContext)
            }) {
                HStack {
                    Image(systemName: "plus.circle")
                    Text(viewModel.addServerButtonTitle)
                }
            }
            .buttonStyle(LinkButtonStyle())
            .padding([.trailing])
        }
    }
}

struct SideBarSplit_Previews: PreviewProvider {
    static var previews: some View {
        SideBarSplitView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
