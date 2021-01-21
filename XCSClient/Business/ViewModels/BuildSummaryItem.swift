//
//  BuildSummaryItem.swift
//  XCSClient
//
//  Created by Alex da Franca on 18.01.21.
//  Copyright © 2021 Farbflash. All rights reserved.
//

import Foundation

struct BuildSummaryItem {
    let name: String
    let error: String
    let date: Date
    let duration: TimeInterval
    
    var dateAndName: String {
        return "\(date)\(name)"
    }
    
    static func itemsFromLog(_ log: String) -> [BuildSummaryItem] {
        let all = log.components(separatedBy: .newlines)
        let filtered = all
            .filter { $0.contains("Completed integration step") ||
                $0.contains("IntegrationStep finished integration with an error:") }
        var asItems = [BuildSummaryItem]()
        var previousItem: BuildSummaryItem?
        for logLine in filtered {
            if let thisItem = BuildSummaryItem(logLine: logLine, previousDate: previousItem?.date) {
            previousItem = thisItem
            asItems.append(thisItem)
            }
        }
        return asItems
    }
    
    var nameAndDuration: String {
        return "\(name)\t(\(formattedDuration))"
    }
    
    private static var formatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .short
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = .default
        return formatter
    }()
    
    private var formattedDuration: String {
        return Self.formatter.string(from: duration) ?? ""
    }
}

extension BuildSummaryItem {
    init?(logLine: String, previousDate: Date?) {
        let parts = logLine.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
        guard parts.count > 9 else {
            return nil
        }
        let comps = Calendar.current.dateComponents([.year], from: Date())
        let dateString = parts[0...2].joined(separator: " ")
        let dateWithYear = "\(comps.year ?? 2020) \(dateString)" // without a year we do not get a proper date...
        guard let datum = DateFormatter.buildLogDate.date(from: dateWithYear) else {
            return nil
        }
        date = datum
        if logLine.contains("finished integration with an error:") {
            name = String(parts[5]
                            .dropFirst(3)
                            .dropLast(15)
            )
            let quoted = logLine.components(separatedBy: "\"")
            if quoted.count > 1 {
                error = quoted[1]
            } else {
                error = parts[9..<parts.count].joined(separator: " ")
            }
        } else {
            name = String(parts[8]
                            .dropFirst(3)
                            .dropLast(15)
            )
            error = ""
        }
        
        if let previousDate = previousDate {
            duration = date.timeIntervalSince(previousDate)
        } else {
            duration = 0
        }
    }
}
