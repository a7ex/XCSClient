//
//  AnimatingIcon.swift
//  XCSClient
//
//  Created by Alex da Franca on 02.01.21.
//  Copyright © 2021 Farbflash. All rights reserved.
//

import SwiftUI

struct AnimatingIcon: View {
    @State private var isAnimating = false
    
    var body: some View {
        Image(systemName: "ellipsis.circle")
            .opacity(isAnimating ? 1.0: 0.0)
            .scaleEffect(isAnimating ? 1.0: 0.7, anchor: .center)
            .animation(
                Animation.easeInOut(duration: 0.6)
                    .repeatForever(autoreverses: true)
            )
            .onAppear {
                isAnimating = true
            }
    }
}

struct AnimatingIcon_Previews: PreviewProvider {
    static var previews: some View {
        AnimatingIcon()
    }
}
