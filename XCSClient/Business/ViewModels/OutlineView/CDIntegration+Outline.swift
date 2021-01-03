//
//  CDIntegration+Outline.swift
//  XCSClient
//
//  Created by Alex da Franca on 26.12.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import SwiftUI

extension CDIntegration: OutlineElement {
    
    private static let fullDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
    var children: [OutlineElement]? {
        return nil
    }
    
    var title: String {
        var title = "(\(number)) "
        if let date = queuedDate {
            title += "\(Self.fullDateFormatter.string(from: date))\t"
        }
        if result == "unknown" {
            title += currentStep ?? ""
        } else {
            title += result ?? ""
        }
        return title
    }
    
    var destination: AnyView {
        let connector = bot?.server?.connector ?? XCSConnector.previewServerConnector
        return AnyView(
            CDIntegrationView(integrationID: self.id ?? "")
                .environmentObject(connector)
        )
    }
    
}
