//
//  SplitType.swift
//  SplitEase
//
//  Created for SplitEase.
//

import Foundation

public enum SplitType: String, CaseIterable, Codable, Identifiable, Sendable {
    case equal = "equal"
    case exact = "exact"
    case percentage = "percentage"
    case shares = "shares"
    case itemized = "itemized"
    case adjustment = "adjustment"

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .equal: return "Equally"
        case .exact: return "Exact Amounts"
        case .percentage: return "Percentages"
        case .shares: return "By Shares"
        case .itemized: return "Itemized Bill"
        case .adjustment: return "Adjustments"
        }
    }

    public var systemImage: String {
        switch self {
        case .equal: return "divide.circle.fill"
        case .exact: return "indianrupeesign.circle.fill"
        case .percentage: return "percent"
        case .shares: return "chart.pie.fill"
        case .itemized: return "list.bullet.rectangle.portrait.fill"
        case .adjustment: return "slider.horizontal.2.square.badge.arrow.down"
        }
    }

    public var subtitle: String {
        switch self {
        case .equal: return "Split the total bill equally between everyone"
        case .exact: return "Specify the exact amount each person owes"
        case .percentage: return "Enter percentages that add up to 100%"
        case .shares: return "Assign weights or shares (e.g., 2 shares, 1 share)"
        case .itemized: return "Assign specific items from the receipt"
        case .adjustment: return "Split equally with custom +/- adjustments"
        }
    }
}
