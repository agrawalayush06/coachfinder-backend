//
//  QuickAddParser.swift
//  SplitEase
//
//  Created for SplitEase.
//

import Foundation

public struct ParsedQuickAddResult {
    public var title: String
    public var amountMinorUnits: Int64
    public var participantNames: [String]
    public var splitType: SplitType
}

public struct QuickAddParser {
    /// Parses natural language expense inputs like:
    /// "Dinner 1200 with Ankit and Riya split equally"
    /// "Uber to airport 450 split equally"
    public static func parse(_ text: String, defaultCurrency: Currency = .inr) -> ParsedQuickAddResult? {
        let cleaned = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty else { return nil }

        var amountMinor: Int64 = 0
        var remainingWords: [String] = []

        let tokens = cleaned.components(separatedBy: .whitespaces)

        for token in tokens {
            let stripped = token.replacingOccurrences(of: defaultCurrency.symbol, with: "")
            if let parsed = MinorUnits.parse(stripped, currency: defaultCurrency), parsed > 0, amountMinor == 0 {
                amountMinor = parsed
            } else {
                remainingWords.append(token)
            }
        }

        guard amountMinor > 0 else { return nil }

        var titleWords: [String] = []
        var participants: [String] = []
        var splitType: SplitType = .equal

        var isCollectingParticipants = false

        for word in remainingWords {
            let lower = word.lowercased()
            if lower == "with" {
                isCollectingParticipants = true
                continue
            }
            if lower == "split" || lower == "equally" {
                isCollectingParticipants = false
                continue
            }
            if lower == "and" {
                continue
            }

            if isCollectingParticipants {
                participants.append(word.capitalized)
            } else {
                titleWords.append(word)
            }
        }

        let title = titleWords.isEmpty ? "Expense" : titleWords.joined(separator: " ")

        return ParsedQuickAddResult(
            title: title,
            amountMinorUnits: amountMinor,
            participantNames: participants,
            splitType: splitType
        )
    }
}
