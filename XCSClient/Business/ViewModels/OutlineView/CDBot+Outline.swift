//
//  CDBot+Outline.swift
//  XCSClient
//
//  Created by Alex da Franca on 26.12.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import SwiftUI

extension CDBot: OutlineElement {
    
    var children: [OutlineElement]? {
        guard let integrations = items as? Set<CDIntegration>,
              !integrations.isEmpty else {
            return nil
        }
        let integrationsSubset = Array(
            Array(integrations)
                .sorted { $0.number > $1.number }
                .prefix(max(2, Int(visibleItems)))
        ) as [OutlineElement]
        let showLess: [OutlineElement]
        if visibleItems > 2 {
            showLess = [ShowLessCellModel(bot: self)]
        } else {
            showLess = [OutlineElement]()
        }
        return  showLess + integrationsSubset + [ShowMoreLessCellModel(bot: self)]
    }
    
    var title: String {
        return name ?? ""
    }
    
    var statusColor: Color {
        guard let integrations = children?.filter({ $0 is CDIntegration }) as? [CDIntegration],
              let firstIntegration = integrations.first(
                where: { $0.integrationResult != .canceled }
              ) else {
            return .gray
        }
        return firstIntegration.statusColor
    }
    
    var destination: AnyView {
        let connector = server?.connector ?? XCSConnector.previewServerConnector
        return AnyView(
            CDBotView(botID: self.id ?? "")
                .environmentObject(connector)
        )
    }
    
    var botCurrentItemsCount: Int {
        return Int(items?.count ?? 0)
    }
    
    var visibleItemsCount: Int {
        get {
            return max(2, Int(visibleItems))
        }
        set {
            let numberOfVisibleItems = Int64(max(2, newValue))
            visibleItems = numberOfVisibleItems
            if numberOfVisibleItems > (items?.count ?? 0) {
                updateIntegrationsFromBackend()
            }
        }
    }
}

extension ScheduleType {
    var string: String {
        switch self {
        case .periodically:
            return "Periodically"
        case .onCommit:
            return "On Commit"
        case .manually:
            return "Manually"
        case .none:
            return ""
        }
    }
    static var allStringValues: [String] {
        return ScheduleType.allCases
            .map { $0.string }
            .filter { !$0.isEmpty }
    }
}

extension WeeklyScheduleDay {
    var string: String {
        switch self {
        case .monday:
            return "Monday"
        case .tuesday:
            return "Tuesday"
        case .wednesday:
            return "Wednesday"
        case .thursday:
            return "Thursday"
        case .friday:
            return "Friday"
        case .saturday:
            return "Saturday"
        case .sunday:
            return "Sunday"
        case .none:
            return ""
        }
    }
}

extension PeriodicScheduleInterval {
    var string: String {
        switch self {
        case .daily:
            return "Daily"
        case .hourly:
            return "Hourly"
        case .weekly:
            return "Weekly"
        case .none:
            return ""
        }
    }
}
