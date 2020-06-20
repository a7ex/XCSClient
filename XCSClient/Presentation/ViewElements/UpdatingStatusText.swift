//
//  UpdatingStatusText.swift
//  XCSClient
//
//  Created by Alex da Franca on 16.06.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import SwiftUI

struct UpdatingStatusText: View {
    @EnvironmentObject var connector: XCSConnector
    let botId: String
    let initialStatus: String
    
    @State private var inProgressBot = ""
    @State private var currentStatus = ""
    private let timer = Timer.publish(every: 10, tolerance: 0.5, on: .main, in: .common).autoconnect()
    
    init(currentStatus: String, botId: String) {
        self.botId = botId
        initialStatus = currentStatus
    }
    
    var body: some View {
        Text(currentStatus)
            .onReceive(timer) { (timer) in
                self.refreshLastIntegration(of: self.inProgressBot)
        }
        .onAppear {
            self.currentStatus = self.initialStatus
            self.inProgressBot = self.botId
        }
    }
    
    private func refreshLastIntegration(of botId: String) {
        guard !inProgressBot.isEmpty else {
            return
        }
        connector.getIntegrationsList(for: inProgressBot, last: 1) { (result) in
            if case let .success(integrations) = result {
                if let integration = integrations.first,
                    let result = integration.result,
                    result == .unknown {
                    self.currentStatus = integration.currentStep ?? ""
                } else {
                    self.inProgressBot = ""
                }
            }
        }
    }
}

struct UpdatingStatusText_Previews: PreviewProvider {
    static var previews: some View {
        UpdatingStatusText(currentStatus: "integrating", botId: "123")
    }
}
