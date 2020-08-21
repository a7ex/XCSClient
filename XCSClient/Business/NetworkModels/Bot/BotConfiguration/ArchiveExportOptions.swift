//
//  ArchiveExportOptions.swift
//  XCSClient
//
//  Created by Alex da Franca on 21.08.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import Foundation

struct ArchiveExportOptions: Codable {
    var name: String?
    var createdAt: Date?
    var exportOptions: IPAExportOptions?
}

// This is the content of the exportOptions.plist
// which is used to create the IPA from the archive
struct IPAExportOptions: Codable {
    var compileBitcode: Bool? // true,
    var destination: String? // "export",
    var method: String? // "enterprise",
    var provisioningProfiles: [String: String]?
    var signingCertificate: String? // "Apple Distribution",
    var signingStyle: String? // "manual",
    var stripSwiftSymbols: Bool? // true,
    var teamID: String? // "SF3Y2F6HZ3",
    var thinning: String? // "<none>"
}

//"archiveExportOptions": {
//    "createdAt": "2020-08-21T14:19:03.456Z",
//    "exportOptions": {
//        "compileBitcode": true,
//        "destination": "export",
//        "method": "enterprise",
//        "provisioningProfiles": {
//            "com.dhl.demp.dmac": "DMAC"
//        },
//        "signingCertificate": "Apple Distribution",
//        "signingStyle": "manual",
//        "stripSwiftSymbols": true,
//        "teamID": "SF3Y2F6HZ3",
//        "thinning": "<none>"
//    },
//    "name": "exportOptionsProd.plist"
//}
