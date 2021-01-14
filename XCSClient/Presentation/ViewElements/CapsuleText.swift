//
//  CapsuleText.swift
//  XCSClient
//
//  Created by Alex da Franca on 12.01.21.
//  Copyright © 2021 Farbflash. All rights reserved.
//

import SwiftUI

struct CapsuleText: View {
    let content: String
    let color: Color
    
    var body: some View {
        Text(content)
            .font(.caption)
            .foregroundColor(.white)
            .padding(.horizontal, 5.0)
            .padding(.vertical, 2.0)
            .frame(minWidth: 20)
            .background(
                Capsule()
                    .fill(color)
            )
    }
}

struct CapsuleText_Previews: PreviewProvider {
    static var previews: some View {
        CapsuleText(content: "10(+3)", color: .red)
    }
}
