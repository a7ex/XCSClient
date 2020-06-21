//
//  UpdatingStatusText.swift
//  XCSClient
//
//  Created by Alex da Franca on 16.06.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import SwiftUI
import Combine

struct UpdatingStatusText: View {
    @EnvironmentObject var connector: XCSConnector
    let botId: String
    let initialStatus: String
    
    @State private var inProgressBot = ""
    @State private var currentStatus = ""
    
    @State private var cancellable: AnyCancellable?
    private let timerPublisher = Timer.publish(every: 10, tolerance: 0.5, on: .main, in: .common)
    
    init(currentStatus: String, botId: String) {
        self.botId = botId
        initialStatus = currentStatus
    }
    
    var body: some View {
        Text(currentStatus)
        .onAppear {
            self.cancellable = self.timerPublisher
                .autoconnect()
                .sink { timer in
                    self.refreshLastIntegration(of: self.inProgressBot)
            }
            
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
                    self.cancellable?.cancel()
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
