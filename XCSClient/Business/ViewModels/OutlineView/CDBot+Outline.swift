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
        return  integrationsSubset + [ShowMoreLessCellModel(bot: self)]
    }
    
    var title: String {
        return name ?? ""
    }
    
    var statusColor: Color {
        return firstIntegration?.statusColor ?? .gray
    }
    
    var lastEventDate: Date {
        return firstCDIntegration?.queuedDate ?? .distantPast
    }
    
    var sortedStatus: Int {
        return firstCDIntegration?.sortedStatus ?? 0
    }
    
    var firstIntegrationStatus: some View {
        guard let summary = firstCDIntegration?.buildResultSummary else {
            return CapsuleText(
                content: "",
                color: .clear
            )
        }
        if summary.errorCount > 0 {
            return CapsuleText(
                content: "\(summary.errorCount)\(signedNumberString(from: summary.errorChange))",
                color: Color(Colors.error)
            )
        }
        if summary.testFailureCount > 0 {
            return CapsuleText(
                content: "\(summary.testFailureCount)\(signedNumberString(from: summary.testFailureChange))",
                color: Color(Colors.testFailures)
            )
        }
        if summary.warningCount > 0 {
            return CapsuleText(
                content: "\(summary.warningCount)\(signedNumberString(from: summary.warningChange))",
                color: Color(Colors.warning)
            )
        }
        return CapsuleText(content: "", color: .clear)
    }
    
    private func signedNumberString(from number: Int16) -> String {
        guard number != 0 else {
            return ""
        }
        guard number > 0 else {
            return " (\(number))"
        }
        return " (+\(number))"
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
    
    var systemIconName: String {
        return "gearshape.fill"
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
