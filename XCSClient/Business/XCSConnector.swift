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
    
    func delete(_ bot: Bot, completion: @escaping (Result<Bot, Error>) -> Void) {
        
    }
}
