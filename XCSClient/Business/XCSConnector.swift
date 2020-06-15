//
//  XCSConnector.swift
//  XCSClient
//
//  Created by Alex da Franca on 12.06.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import Foundation

class XCSConnector: ObservableObject {
    let server: Server
    
    init(server: Server) {
        self.server = server
    }
    
    func getBotList(completion: @escaping (Result<[Bot], Error>) -> Void) {
        DispatchQueue.global(qos: .background).async {
            let rslt = self.server.getBotList()
            DispatchQueue.main.async {
                completion(rslt)
            }
        }
    }
    
    func getIntegrationsList(for botId: String, last: Int = 3, completion: @escaping (Result<[Integration], Error>) -> Void) {
        DispatchQueue.global(qos: .background).async {
            let rslt = self.server.getIntegrations(for: botId, last: last)
            DispatchQueue.main.async {
                completion(rslt)
            }
        }
    }
    
    func integrate(_ bot: Bot, completion: @escaping (Result<Integration, Error>) -> Void) {
        guard let botId = bot.id, !botId.isEmpty else {
            completion(.failure(NSError(message: "Parameter error")))
            return
        }
        DispatchQueue.global(qos: .background).async {
            let rslt = self.server.integrate(botId)
            DispatchQueue.main.async {
                completion(rslt)
            }
        }
    }
    
    func duplicate(_ bot: Bot, completion: @escaping (Result<Bot, Error>) -> Void) {
        guard let botId = bot.id, !botId.isEmpty else {
            completion(.failure(NSError(message: "Parameter error")))
            return
        }
        DispatchQueue.global(qos: .background).async {
            let rslt = self.server.duplicateBot(botId)
            DispatchQueue.main.async {
                completion(rslt)
            }
        }
    }
    
    func delete(_ bot: Bot, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let botId = bot.id, !botId.isEmpty,
            let revId = bot.rev, !revId.isEmpty else {
                completion(.failure(NSError(message: "Parameter error")))
                return
        }
        DispatchQueue.global(qos: .background).async {
            let rslt = self.server.deleteBot(botId: botId, revId: revId)
            DispatchQueue.main.async {
                completion(rslt)
            }
        }
    }
    
    func exportBotSettings(of bot: Bot, completion: @escaping (Result<Data, Error>) -> Void) {
        var duplicate = bot
        duplicate.requiresUpgrade = false
        duplicate.duplicatedFrom = bot.id ?? ""
        
        duplicate.id = nil
        duplicate.rev = nil
        duplicate.tinyID = nil
        duplicate.docType = nil
        duplicate.integrationCounter = nil
        duplicate.lastRevisionBlueprint = nil
        duplicate.sourceControlBlueprintIdentifier = nil
        
        duplicate.configuration?.sourceControlBlueprint?.identifierKey = UUID().uuidString
        
        completion(.success(Data(duplicate.asBodyParamater.utf8)))
    }
    
    func applySettings(at fileUrl: URL, fileName: String, toBot bot: Bot, completion: @escaping (Result<Bot, Error>) -> Void) {
        guard let botId = bot.id, !botId.isEmpty else {
            completion(.failure(NSError(message: "Parameter error")))
            return
        }
        DispatchQueue.global(qos: .background).async {
            let rslt = self.server.applySettings(at: fileUrl, fileName: fileName, toBot: botId)
            DispatchQueue.main.async {
                completion(rslt)
            }
        }
    }
    
    func exportIntegrationAssets(of integration: Integration, to targetUrl: URL, completion: @escaping (Result<Bool, Error>) -> Void) {
        DispatchQueue.global(qos: .background).async {
            let rslt = self.server.downloadAssets(for: integration.id, to: targetUrl)
            DispatchQueue.main.async {
                completion(rslt)
            }
        }
    }
    
    func downloadAssets(at path: String, to targetUrl: URL, completion: @escaping (Result<Bool, Error>) -> Void) {
        DispatchQueue.global(qos: .background).async {
            let rslt = self.server.downloadAsset(path, to: targetUrl)
            DispatchQueue.main.async {
                completion(rslt)
            }
        }
    }
    
    func loadAsset(at path: String, completion: @escaping (Result<Data, Error>) -> Void) {
        DispatchQueue.global(qos: .background).async {
            let rslt = self.server.loadAsset(path)
            DispatchQueue.main.async {
                completion(rslt)
            }
        }
    }
    
}
