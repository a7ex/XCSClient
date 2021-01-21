//
//  CDBuildServiceSummaryItem+Codable.swift
//  XCSClient
//
//  Created by Alex da Franca on 18.01.21.
//  Copyright © 2021 Farbflash. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObjectContext {
    @discardableResult
    func summaryItem(from item: BuildSummaryItem) -> CDBuildServiceSummaryItem {
        let newItem = CDBuildServiceSummaryItem(context: self)
        newItem.update(with: item)
        insert(newItem)
        return newItem
    }
}

extension CDBuildServiceSummaryItem {
    func update(with buildSummaryItem: BuildSummaryItem) {
        date = buildSummaryItem.date
        name = buildSummaryItem.name
        error = buildSummaryItem.error
        duration = Int64(buildSummaryItem.duration)
    }
    var asCodableObject: BuildSummaryItem {
        return BuildSummaryItem(
            name: name ?? "-No name-",
            error: error ?? "",
            date: date ?? Date.distantPast,
            duration: TimeInterval(duration)
        )
    }
}
