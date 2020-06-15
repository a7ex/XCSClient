//
//  LabeledBooleanValue.swift
//  XCSClient
//
//  Created by Alex da Franca on 14.06.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import SwiftUI

struct LabeledBooleanValue: View {
    let label: String
    let value: Bool
    
    var body: some View {
        HStack(alignment: .top) {
            InfoLabel(content: label)
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .trailing)
            .padding([.bottom], 4)
            Text(value ? "✅": "❌")
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct LabeledBooleanValue_Previews: PreviewProvider {
    static var previews: some View {
        LabeledBooleanValue(label: "Label", value: true)
    }
}
