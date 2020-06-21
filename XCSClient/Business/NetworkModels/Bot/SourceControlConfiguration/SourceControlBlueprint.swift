//
//  SourceControlBlueprint.swift
//  xcodeserverclient
//
//  Created by Alex da Franca on 04.06.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import Foundation

struct SourceControlBlueprint: Codable {
//    var DVTSourceControlWorkspaceBlueprintAdditionalValidationRemoteRepositoriesKey: [Any]
    var identifierKey: String? // unique id for each blueprint
    var locationsKey: [String: SourceControlLocation]?
    
    // The name for the blueprint, typically the name of the Xcode project or workspace. e.g. "DHLPaket"
    var nameKey: String?
    
    // The identifier of the working copy containing the Xcode project or workspace to build,
    // considered the primary working copy. Value: string (repository identifier)
    var primaryRemoteRepositoryKey: String? // "D7781C35E1A99B472120941FF3F007A808515183"
    
    // The relative path in the primary working copy to the Xcode project or workspace to build
    var relativePathToProjectKey: String? // "DHLPaket.xcworkspace"
    
    var remoteRepositoriesKey: [RemoteRepository]?
    var remoteRepositoryAuthenticationStrategiesKey: [String: [String: String]]?
    var version: Int?
    var workingCopyPathsKey: [String: String]?
//    var DVTSourceControlWorkspaceBlueprintWorkingCopyRepositoryLocationsKey: [String: Any]
    var workingCopyStatesKey: [String: Int]?
    
    enum CodingKeys: String, CodingKey {
        case identifierKey = "DVTSourceControlWorkspaceBlueprintIdentifierKey"
        case locationsKey = "DVTSourceControlWorkspaceBlueprintLocationsKey"
        case nameKey = "DVTSourceControlWorkspaceBlueprintNameKey"
        case primaryRemoteRepositoryKey = "DVTSourceControlWorkspaceBlueprintPrimaryRemoteRepositoryKey"
        case relativePathToProjectKey = "DVTSourceControlWorkspaceBlueprintRelativePathToProjectKey"
        case remoteRepositoriesKey = "DVTSourceControlWorkspaceBlueprintRemoteRepositoriesKey"
        case remoteRepositoryAuthenticationStrategiesKey = "DVTSourceControlWorkspaceBlueprintRemoteRepositoryAuthenticationStrategiesKey"
        case version = "DVTSourceControlWorkspaceBlueprintVersion"
        case workingCopyPathsKey = "DVTSourceControlWorkspaceBlueprintWorkingCopyPathsKey"
        case workingCopyStatesKey = "DVTSourceControlWorkspaceBlueprintWorkingCopyStatesKey"
    }
}
