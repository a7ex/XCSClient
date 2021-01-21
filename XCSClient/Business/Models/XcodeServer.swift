//
//  XcodeServer.swift
//  XCSClient
//
//  Created by Alex da Franca on 17.06.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import Foundation

struct XcodeServer: Codable, Hashable {
    let ipAddress: String
    let name: String
    let sshAddress: String
    let sshUser: String
    let netRCFilename: String
}
