//
//  SelectableListRow.swift
//  XCSClient
//
//  Created by Alex da Franca on 12.07.21.
//  Copyright © 2021 Farbflash. All rights reserved.
//

import SwiftUI

struct SelectableListRow: View {
    var title: String
    var isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: isSelected ? "checkmark.circle.fill": "circle")
                    .foregroundColor(isSelected ? Color.success: Color.canceled)
                Text(title)
                    .foregroundColor(isSelected ? Color.black: Color.canceled)
            }
            .padding(.leading)
        }
        .buttonStyle(BorderlessButtonStyle())
    }
}
