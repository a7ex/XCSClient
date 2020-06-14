//
//  InfoLabel.swift
//  XCSClient
//
//  Created by Alex da Franca on 14.06.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import SwiftUI

struct InfoLabel: View {
    let content: String
    
    var body: some View {
        Text(content)
            .fontWeight(.bold)
    }
}

struct InfoLabel_Previews: PreviewProvider {
    static var previews: some View {
        InfoLabel(content: "Label:")
    }
}
