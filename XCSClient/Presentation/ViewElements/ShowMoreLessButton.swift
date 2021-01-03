//
//  ShowMoreLessButton.swift
//  XCSClient
//
//  Created by Alex da Franca on 02.01.21.
//  Copyright © 2021 Farbflash. All rights reserved.
//

import SwiftUI

struct ShowMoreLessButton: View {
    let showMoreDisabled: Bool
    let showLessDisabled: Bool
    let showMoreTapped: () -> Void
    let showLessTapped: () -> Void
    let showAllTapped: () -> Void
    
    var body: some View {
        HStack {
            Spacer()
            Button(action: showMoreTapped) {
                HStack {
                    Image(systemName: "arrow.down")
                    Text("More…")
                }
            }
            .font(.caption)
            .buttonStyle(LinkButtonStyle())
            .disabled(showMoreDisabled)
            Button(action: showLessTapped) {
                Image(systemName: "arrow.up")
                Text("Less…")
            }
            .font(.caption)
            .buttonStyle(LinkButtonStyle())
            .disabled(showLessDisabled)
            Button(action: showAllTapped) {
                Image(systemName: "arrow.down")
                Text("All…")
            }
            .font(.caption)
            .buttonStyle(LinkButtonStyle())
            .disabled(showMoreDisabled)
        }
    }
}

struct ShowMoreLessButton_Previews: PreviewProvider {
    static var previews: some View {
        ShowMoreLessButton(
            showMoreDisabled: true,
            showLessDisabled: false,
            showMoreTapped: {},
            showLessTapped: {},
            showAllTapped: {}
        )
    }
}
