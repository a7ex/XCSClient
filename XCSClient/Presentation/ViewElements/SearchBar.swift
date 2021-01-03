//
//  SearchBar.swift
//  XCSClient
//
//  Created by Alex da Franca on 21.06.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import SwiftUI

struct SearchBar: View {
    @Binding var query: String
    
    var body: some View {
        HStack(spacing: 0) {
            Spacer()
            Text("🔍")
            TextField("Filter bots", text: $query)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(8)
            Button(action: { self.query = "" }) {
                Text("✖︎")
                    .opacity(query.count == 0 ? 0.5 : 1.0)
            }
            .disabled(query.count == 0)
            .padding(.trailing, 8)
        }
    }
}
