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
    let name: String
    
    init(server: Server, name: String) {
        self.server = server
        self.name = name
    }
    
    // Mock for use in previews
    static var previewServerConnector: XCSConnector {
        return XCSConnector(
            server: Server(
                xcodeServerAddress: "",
                sshEndpoint: "",
                netrcFilename: ""),
            name: "Untitled Xcode Server"
        )
    }
    
    func findIpa(
        machineName: String,
        botID: String,
        botName: String,
        integrationNumber: Int,
        completion: @escaping (String) -> Void
    ) {
        DispatchQueue.global(qos: .userInitiated).async {
            completion(self.server.findIpaPath(machineName: machineName, botID: botID, botName: botName, integrationNumber: integrationNumber))
        }
    }
    
    func getBotList(completion: @escaping (Result<[Bot], Error>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let rslt = self.server.getBotList()
            DispatchQueue.main.async {
                completion(rslt)
            }
        }
    }
    
    func getIntegrationsList(for botId: String, last: Int = 3, completion: @escaping (Result<[Integration], Error>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let rslt = self.server.getIntegrations(for: botId, last: last)
            DispatchQueue.main.async {
                completion(rslt)
            }
        }
    }
    
    func integrate(_ botId: String?, completion: @escaping (Result<Integration, Error>) -> Void) {
        guard let botId = botId, !botId.isEmpty else {
            completion(.failure(NSError(message: "Parameter error")))
            return
        }
        DispatchQueue.global(qos: .userInitiated).async {
            let rslt = self.server.integrate(botId)
            DispatchQueue.main.async {
                completion(rslt)
            }
        }
    }
    
    func cancelIntegration(_ integrationId: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard !integrationId.isEmpty else {
            completion(.failure(NSError(message: "Parameter error")))
            return
        }
        DispatchQueue.global(qos: .userInitiated).async {
            let rslt = self.server.cancelIntegration(integrationId)
            DispatchQueue.main.async {
                completion(rslt)
            }
        }
    }
    
    func duplicateBot(with botId: String, completion: @escaping (Result<Bot, Error>) -> Void) {
        guard !botId.isEmpty else {
            completion(.failure(NSError(message: "Parameter error")))
            return
        }
        DispatchQueue.global(qos: .userInitiated).async {
            let rslt = self.server.duplicateBot(botId)
            DispatchQueue.main.async {
                completion(rslt)
            }
        }
    }
    
    func deleteBot(with botId: String, revId: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard !botId.isEmpty,
              !revId.isEmpty else {
                completion(.failure(NSError(message: "Parameter error")))
                return
        }
        DispatchQueue.global(qos: .userInitiated).async {
            let rslt = self.server.deleteBot(botId: botId, revId: revId)
            DispatchQueue.main.async {
                completion(rslt)
            }
        }
    }
    
    func applySettings(at fileUrl: URL, fileName: String, toBot botId: String, completion: @escaping (Result<Bot, Error>) -> Void) {
        guard !botId.isEmpty else {
            completion(.failure(NSError(message: "Parameter error")))
            return
        }
        DispatchQueue.global(qos: .userInitiated).async {
            let rslt = self.server.applySettings(at: fileUrl, fileName: fileName, toBot: botId)
            DispatchQueue.main.async {
                completion(rslt)
            }
        }
    }
    
    func exportIntegrationAssets(of integrationId: String, to targetUrl: URL, completion: @escaping (Result<Bool, Error>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let rslt = self.server.downloadAssets(for: integrationId, to: targetUrl)
            DispatchQueue.main.async {
                completion(rslt)
            }
        }
    }
    
    func downloadAssets(at path: String, to targetUrl: URL, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard !path.isEmpty else {
            completion(.failure(Server.ServerError.parameterError))
            return
        }
        DispatchQueue.global(qos: .userInitiated).async {
            let rslt = self.server.downloadAsset(path, to: targetUrl)
            DispatchQueue.main.async {
                completion(rslt)
            }
        }
    }
    
    func loadAsset(at path: String, completion: @escaping (Result<Data, Error>) -> Void) {
        guard !path.isEmpty else {
            completion(.failure(Server.ServerError.parameterError))
            return
        }
        DispatchQueue.global(qos: .userInitiated).async {
            let rslt = self.server.loadAsset(path)
            DispatchQueue.main.async {
                completion(rslt)
            }
        }
    }
    
    func scpAsset(at path: String, to targetUrl: URL, machineName: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let rslt = self.server.scpFromBot(path, to: targetUrl, machineName: machineName)
            DispatchQueue.main.async {
                completion(rslt)
            }
        }
    }
    
}
