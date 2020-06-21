//
//  BranchOptionsKey.swift
//  XCSClient
//
//  Created by Alex da Franca on 21.06.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import Foundation

enum BranchOptionsKey: Int, Codable {
    case normalRemoteBranch = 4
    case primaryRemoteBranch = 5 // necessary for trunk-like branch in Subversion
}
