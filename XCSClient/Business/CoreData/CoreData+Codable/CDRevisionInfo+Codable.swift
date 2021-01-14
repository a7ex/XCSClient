//
//  CDRevisionInfo+Codable.swift
//  XCSClient
//
//  Created by Alex da Franca on 12.01.21.
//  Copyright © 2021 Farbflash. All rights reserved.
//

import Foundation
import CoreData

extension CDRevisionInfo {
    func update(with revisionInfo: RevisionInfo) {
        author = revisionInfo.author
        date = revisionInfo.date
        comment = revisionInfo.comment
    }
}
