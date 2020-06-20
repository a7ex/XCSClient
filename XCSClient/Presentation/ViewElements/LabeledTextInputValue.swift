//
//  LabeledTextInputValue.swift
//  XCSClient
//
//  Created by Alex da Franca on 18.06.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import SwiftUI

struct LabeledTextInputValue: View {
    let label: String
    @Binding var value: String
    
    var body: some View {
        HStack(alignment: .top) {
            InfoLabel(content: label)
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .trailing)
                .padding([.bottom], 4)
            TextField(label, text: $value)
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct LabeledTextInputValue_Previews: PreviewProvider {
    static var previews: some View {
        LabeledStringValue(label: "Label", value: "Value")
    }
}
