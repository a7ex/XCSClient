//
//  RevisionInfo.swift
//  XCSClient
//
//  Created by Alex da Franca on 26.08.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import Foundation

struct RevisionInfo {
    let author: String
    let date: String
    let comment: String
    
    init(snippet: String) {
        let recStrings = snippet.components(separatedBy: .newlines)
        var revisionLines = Array(recStrings.dropFirst())
        if let value = revisionLines.first {
            author = value
            revisionLines.remove(at: 0)
        } else {
            author = ""
        }
        if let value = revisionLines.first {
            date = value
            revisionLines.remove(at: 0)
        } else {
            date = ""
        }
        comment = revisionLines.joined(separator: "\n")
    }
    
    var isEmpty: Bool {
        return author.isEmpty && comment.isEmpty
    }
}
