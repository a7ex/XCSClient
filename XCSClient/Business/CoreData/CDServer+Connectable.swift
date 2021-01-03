//
//  CDServer+Connectable.swift
//  XCSClient
//
//  Created by Alex da Franca on 31.12.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import Foundation

extension CDServer {
    var connector: XCSConnector {
        return XCSConnector(
            server: Server(
                xcodeServerAddress: ipAddress ?? "",
                sshEndpoint: "\(sshUser ?? "")@\(sshAddress ?? "")",
                netrcFilename: netRCFilename ?? ""
            ),
            name: name ?? "Untitled"
        )
    }
}

enum ServerReachabilty: Int {
    case unknown, connecting, unreachable, reachable
}
