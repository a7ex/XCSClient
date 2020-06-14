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
        HStack {
            Text(label)
                .frame(minWidth: 200, alignment: .trailing)
            TextField("Enter \(label)", text: $content)
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
