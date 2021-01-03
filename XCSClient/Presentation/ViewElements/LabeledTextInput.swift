//
//  LabeledTextInput.swift
//  XCSClient
//
//  Created by Alex da Franca on 14.06.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import SwiftUI

struct LabeledTextInput: View {
    let label: String
    @Binding var content: String
    
    var body: some View {
        LiveLabeledTextInput(label: label, content: $content, onCommit: {})
    }
}

struct LiveLabeledTextInput: View {
    let label: String
    @Binding var content: String
    let onCommit: (() -> Void)
    
    var body: some View {
        HStack {
            InfoLabel(content: label)
                .frame(minWidth: 100, maxWidth: 160, alignment: .leading)
            TextField("Enter \(label)", text: $content, onCommit: onCommit)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
}

struct LabeledTextInput_Previews: PreviewProvider {
    @State private static var xcsServerAddress = ""
    static var previews: some View {
        LabeledTextInput(label: "Server address", content: $xcsServerAddress)
    }
}
