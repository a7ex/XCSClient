//
//  RemoteRepository.swift
//  xcodeserverclient
//
//  Created by Alex da Franca on 04.06.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import Foundation

struct RemoteRepository: Codable {
    var identifierKey: String? // "D7781C35E1A99B472120941FF3F007A808515183",
    var systemKey: String? // "com.apple.dt.Xcode.sourcecontrol.Git",
    var urlKey: String? // "https://git.dhl.com/DHL-PAKET-APP/paketapp_ios.git"
    
    enum CodingKeys: String, CodingKey {
        case identifierKey = "DVTSourceControlWorkspaceBlueprintRemoteRepositoryIdentifierKey"
        case systemKey = "DVTSourceControlWorkspaceBlueprintRemoteRepositorySystemKey"
        case urlKey = "DVTSourceControlWorkspaceBlueprintRemoteRepositoryURLKey"
    }
}
