//
//  WorkspaceBlueprintLocationType.swift
//  XCSClient
//
//  Created by Alex da Franca on 21.06.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import Foundation

enum WorkspaceBlueprintLocationType: String, Codable {
    case branch = "DVTSourceControlBranch"
    case pathLocation = "DVTSourceControlPathLocation" // svn only
    case lockedRevisionLocation = "DVTSourceControlLockedRevisionLocation" // git only
}
