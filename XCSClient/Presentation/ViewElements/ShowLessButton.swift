//
//  ShowLessButton.swift
//  XCSClient
//
//  Created by Alex da Franca on 02.01.21.
//  Copyright © 2021 Farbflash. All rights reserved.
//

import SwiftUI

struct ShowLessButton: View {
    let showLessTapped: () -> Void
    
    var body: some View {
        HStack {
            Spacer()
            Button(action: showLessTapped) {
                HStack {
                    Image(systemName: "arrow.up")
                    Text("Show less…")
                }
            }
            .font(.caption)
            .buttonStyle(LinkButtonStyle())
        }
    }
}

struct ShowLessButton_Previews: PreviewProvider {
    static var previews: some View {
        ShowLessButton(showLessTapped: {})
    }
}
