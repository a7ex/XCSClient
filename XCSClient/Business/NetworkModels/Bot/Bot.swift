//
//  Bot.swift
//  xcodeserverclient
//
//  Created by Alex da Franca on 04.06.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import Foundation

struct Bot: Codable {
    var id: String?
    var rev: String?
    var configuration: BotConfiguration?
    var name: String
    var tinyID: String?
    var docType: String?
    var type: Int?
    var group: BotGroup?
    var integrationCounter: Int?
    var lastRevisionBlueprint: SourceControlBlueprint?
    var sourceControlBlueprintIdentifier: String?
    var requiresUpgrade: Bool?
    var duplicatedFrom: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case rev = "_rev"
        case docType = "doc_type"
        case integrationCounter = "integration_counter"
        case configuration, name, tinyID, group, type
        case lastRevisionBlueprint
        case sourceControlBlueprintIdentifier
        case requiresUpgrade
    }
    
    var asBodyParamater: String {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(DateFormatter.backendDate)
        encoder.outputFormatting = .prettyPrinted
        guard let body = try? encoder.encode(self),
            let json = String(data: body, encoding: .utf8) else {
                return ""
        }
        return json
    }
}

struct BotGroup: Codable {
    let name: String?
}

extension Array where Element == Bot {
    func find(botIdentifier: String?) -> Bot? {
        guard let botIdentifier = botIdentifier else {
            return nil
        }
        if let num = Int(botIdentifier),
            num < count {
            return self[num]
        } else if botIdentifier.count == 7,
            let bot = first(where: { $0.tinyID == botIdentifier }) {
            return bot
        }
        if let bot = first(where: { $0.name == botIdentifier }) {
            return bot
        }
        if let bot = first(where: { $0.id == botIdentifier }) {
            return bot
        }
        return nil
    }
}
