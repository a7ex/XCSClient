//
//  MainView.swift
//  XCSClient
//
//  Created by Alex da Franca on 24.12.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import SwiftUI

struct MainView: View {
    @StateObject private var credentialsEditorPresentationData = CredentialsEditorData()
    
    var body: some View {
        NavigationView {
            SideBarSplitView()
            initialDetailView
        }
        .navigationViewStyle(DoubleColumnNavigationViewStyle())
        .environmentObject(credentialsEditorPresentationData)
        .overlay(dialogOverlay.environmentObject(credentialsEditorPresentationData))
    }
    
    var dialogOverlay: some View {
        return credentialsEditorPresentationData.dialog
            .opacity(credentialsEditorPresentationData.shouldShow ? 1.0: 0.0)
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
