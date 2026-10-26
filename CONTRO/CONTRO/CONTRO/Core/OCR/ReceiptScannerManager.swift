//
//  ReceiptScannerManager.swift
//  SplitEase
//
//  Created for SplitEase.
//

import UIKit
import Vision

public struct ScannedReceiptItem: Identifiable, Sendable {
    public let id: String = UUID().uuidString
    public var name: String
    public var amountMinorUnits: Int64

    public init(name: String, amountMinorUnits: Int64) {
        self.name = name
        self.amountMinorUnits = amountMinorUnits
    }
}

public struct ScannedReceiptResult: Sendable {
    public var items: [ScannedReceiptItem]
    public var taxMinorUnits: Int64
    public var tipMinorUnits: Int64
    public var totalMinorUnits: Int64
}

public final class ReceiptScannerManager {
    public static func recognizeText(from image: UIImage) async throws -> ScannedReceiptResult {
        guard let cgImage = image.cgImage else {
            throw NSError(domain: "ReceiptScanner", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid image"])
        }

        return try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(returning: ScannedReceiptResult(items: [], taxMinorUnits: 0, tipMinorUnits: 0, totalMinorUnits: 0))
                    return
                }

                let lines = observations.compactMap { $0.topCandidates(1).first?.string }
                let parsed = parseReceiptLines(lines)
                continuation.resume(returning: parsed)
            }

            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    private static func parseReceiptLines(_ lines: [String]) -> ScannedReceiptResult {
        var items: [ScannedReceiptItem] = []
        var totalAmount: Int64 = 0
        var taxAmount: Int64 = 0

        let priceRegex = try? NSRegularExpression(pattern: #"(\d+[.,]\d{2})"#)

        for line in lines {
            let lower = line.lowercased()

            // Look for prices
            let nsString = line as NSString
            let matches = priceRegex?.matches(in: line, range: NSRange(location: 0, length: nsString.length)) ?? []

            if let lastMatch = matches.last {
                let priceStr = nsString.substring(with: lastMatch.range)
                let cleanedPrice = priceStr.replacingOccurrences(of: ",", with: ".")
                if let doubleVal = Double(cleanedPrice) {
                    let minor = MinorUnits.fromMajorDouble(doubleVal)

                    if lower.contains("total") || lower.contains("grand total") || lower.contains("balance due") {
                        totalAmount = minor
                    } else if lower.contains("tax") || lower.contains("gst") || lower.contains("vat") {
                        taxAmount = minor
                    } else {
                        let name = nsString.substring(to: lastMatch.range.location).trimmingCharacters(in: .whitespacesAndNewlines)
                        if !name.isEmpty {
                            items.append(ScannedReceiptItem(name: name, amountMinorUnits: minor))
                        }
                    }
                }
            }
        }

        if totalAmount == 0 {
            totalAmount = items.map(\.amountMinorUnits).reduce(0, +) + taxAmount
        }

        return ScannedReceiptResult(
            items: items,
            taxMinorUnits: taxAmount,
            tipMinorUnits: 0,
            totalMinorUnits: totalAmount
        )
    }
}
