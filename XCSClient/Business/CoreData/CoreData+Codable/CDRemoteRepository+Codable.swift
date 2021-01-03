//
//  CDRemoteRepository+Codable.swift
//  XCSClient
//
//  Created by Alex da Franca on 27.12.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import Foundation
import CoreData

extension CDRemoteRepository {
    func update(with repo: RemoteRepository) {
        identifierKey = repo.identifierKey
        systemKey = repo.systemKey
        urlKey = repo.urlKey
    }
}

extension CDRemoteRepository {
    var asCodableObject: RemoteRepository {
        return RemoteRepository(
            identifierKey: identifierKey,
            systemKey: systemKey,
            urlKey: urlKey
        )
    }
}
