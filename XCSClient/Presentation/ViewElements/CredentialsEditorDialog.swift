//
//  CredentialsEditorDialog.swift
//  XCSClient
//
//  Created by Alex da Franca on 05.07.21.
//  Copyright © 2021 Farbflash. All rights reserved.
//

import SwiftUI

struct CredentialsEditorDialog: View {
    @EnvironmentObject var presentationData: CredentialsEditorData
    
    @State private var username = ""
    @State private var password = ""
    
    private let closeAction: (Bool, String, String) -> Bool
    
    init(closeAction: @escaping (Bool, String, String) -> Bool = { _, _, _ in return true }) {
        self.closeAction = closeAction
    }
    var body: some View {
        ZStack {
            Color.black
                .opacity(0.6)
            VStack {
                Text("This call requires the credentials of the server")
                TextField("Username", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                HStack {
                    Button("Cancel") {
                        if closeAction(false, "", "") {
                            withAnimation {
                                presentationData.shouldShow = false
                            }
                        }
                    }
                    Button("Login") {
                        if closeAction(true, username, password) {
                            withAnimation {
                                presentationData.shouldShow = false
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: 300)
            .padding()
            .background(Color("LighterBackground"))
            .cornerRadius(6)
            .scaleEffect(presentationData.shouldShow ? CGSize(width: 1, height: 1): CGSize(width: 0.7, height: 0.7))
        }
    }
    func dismiss(closeAction: @escaping (Bool, String, String) -> Bool) -> CredentialsEditorDialog {
        return CredentialsEditorDialog(closeAction: closeAction)
    }
}

struct CredentialsEditorDialog_Previews: PreviewProvider {
    static var previews: some View {
        CredentialsEditorDialog()
            .environmentObject(CredentialsEditorData())
    }
}
