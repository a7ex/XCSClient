//
//  RemoteRepository.swift
//  xcodeserverclient
//
//  Created by Alex da Franca on 04.06.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import Foundation

struct RemoteRepository: Codable {
    var identifierKey: String?
    var systemKey: String?
    var urlKey: String?
    
    enum CodingKeys: String, CodingKey {
        case identifierKey = "DVTSourceControlWorkspaceBlueprintRemoteRepositoryIdentifierKey"
        case systemKey = "DVTSourceControlWorkspaceBlueprintRemoteRepositorySystemKey"
        case urlKey = "DVTSourceControlWorkspaceBlueprintRemoteRepositoryURLKey"
    }
}
