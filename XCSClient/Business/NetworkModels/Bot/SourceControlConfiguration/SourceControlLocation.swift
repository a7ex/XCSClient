//
//  SourceControlLocation.swift
//  xcodeserverclient
//
//  Created by Alex da Franca on 04.06.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import Foundation

struct SourceControlLocation: Codable {
    var branchIdentifierKey: String? // branch name e.g. "release/testReleases"
    var branchOptionsKey: BranchOptionsKey? // 4
    var workspaceBlueprintLocationTypeKey: WorkspaceBlueprintLocationType? // "DVTSourceControlBranch"
    var pathIdentifierKey: String? // relative path in repository
    var locationRevisionKey: String? // revision
    
    enum CodingKeys: String, CodingKey {
        case branchIdentifierKey = "DVTSourceControlBranchIdentifierKey"
        case branchOptionsKey = "DVTSourceControlBranchOptionsKey"
        case workspaceBlueprintLocationTypeKey = "DVTSourceControlWorkspaceBlueprintLocationTypeKey"
        case pathIdentifierKey = "DVTSourceControlPathIdentifierKey"
        case locationRevisionKey = "DVTSourceControlLocationRevisionKey"
    }
}
