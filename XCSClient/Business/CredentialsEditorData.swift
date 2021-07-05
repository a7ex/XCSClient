//
//  CredentialsEditorData.swift
//  XCSClient
//
//  Created by Alex da Franca on 05.07.21.
//  Copyright © 2021 Farbflash. All rights reserved.
//

import Foundation

class CredentialsEditorData: ObservableObject {
    @Published var shouldShow = false
    var dialog: CredentialsEditorDialog?
}
