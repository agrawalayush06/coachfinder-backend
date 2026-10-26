//
//  CSVExporter.swift
//  SplitEase
//
//  Created for SplitEase.
//

import Foundation

public struct CSVExporter {
    public static func generateCSV(group: SDGroup) -> String {
        var csv = "Date,Title,Category,Amount,Currency,Split Mode\n"

        for exp in group.activeExpenses {
            let dateStr = exp.date.formatted(date: .numeric, time: .omitted)
            let safeTitle = "\"\(exp.title.replacingOccurrences(of: "\"", with: "\"\""))\""
            let cat = exp.category.displayName
            let amt = String(format: "%.2f", MinorUnits.toMajorDouble(exp.amountMinorUnits, currency: exp.currency))
            let curr = exp.currencyCode
            let mode = exp.splitType.title

            csv += "\(dateStr),\(safeTitle),\(cat),\(amt),\(curr),\(mode)\n"
        }

        return csv
    }
}
