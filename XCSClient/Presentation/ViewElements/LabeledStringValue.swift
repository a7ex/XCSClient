//
//  LabeledStringValue.swift
//  XCSClient
//
//  Created by Alex da Franca on 14.06.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import SwiftUI

struct LabeledStringValue: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack(alignment: .top) {
            InfoLabel(content: label)
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .trailing)
                .padding([.bottom], 4)
            Text(value)
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                .contextMenu {
                    Button(action: {
                        let pb = NSPasteboard.general
                        pb.declareTypes([.string], owner: nil)
                        pb.setString(self.value, forType: .string)
                    }) {
                        Text("Copy")
                    }
            }
        }
    }
}

struct LabeledStringValue_Previews: PreviewProvider {
    static var previews: some View {
        LabeledStringValue(label: "Label", value: "Value")
    }
}
