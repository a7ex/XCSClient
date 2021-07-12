//
//  RevisionInfoView.swift
//  XCSClient
//
//  Created by Alex da Franca on 13.01.21.
//  Copyright © 2021 Farbflash. All rights reserved.
//

import SwiftUI

struct RevisionInfoView: View {
    let revisionInfo: RevisionInfo
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(revisionInfo.author)
                Text(revisionInfo.date)
                Text(revisionInfo.commentHeader)
                    .fontWeight(.bold)
                    .padding(.top, 8)
                    .padding(.bottom, 2)
                Text(revisionInfo.commentBody)
                    .padding(.bottom, 4)
            }
            Spacer()
        }
    }
}

struct RevisionInfoView_Previews: PreviewProvider {
    static var previews: some View {
        RevisionInfoView(revisionInfo: RevisionInfo(author: "Alex", date: "today", comment: "Commit message"))
    }
}
