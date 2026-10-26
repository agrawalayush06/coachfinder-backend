//
//  PDFExporter.swift
//  SplitEase
//
//  Created for SplitEase.
//

import UIKit

public struct PDFExporter {
    public static func generateGroupReport(group: SDGroup) -> Data {
        let pdfMetaData = [
            kCGPDFContextCreator: "SplitEase",
            kCGPDFContextAuthor: "SplitEase iOS",
            kCGPDFContextTitle: "\(group.name) - Expense Report"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]

        let pageWidth: CGFloat = 8.5 * 72.0
        let pageHeight: CGFloat = 11.0 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)

        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)

        return renderer.pdfData { context in
            context.beginPage()

            let titleFont = UIFont.boldSystemFont(ofSize: 24)
            let bodyFont = UIFont.systemFont(ofSize: 12)
            let boldBodyFont = UIFont.boldSystemFont(ofSize: 12)

            var yPosition: CGFloat = 40

            // Title
            let title = "\(group.emoji) \(group.name) - Expense Summary"
            title.draw(at: CGPoint(x: 40, y: yPosition), withAttributes: [.font: titleFont])
            yPosition += 40

            // Group Metadata
            let membersList = group.members.map { $0.name }.joined(separator: ", ")
            let meta = "Members: \(membersList)"
            meta.draw(at: CGPoint(x: 40, y: yPosition), withAttributes: [.font: bodyFont])
            yPosition += 30

            // Table Header
            let headers = ["Date", "Expense Title", "Category", "Amount"]
            let colX: [CGFloat] = [40, 140, 360, 480]

            for (idx, h) in headers.enumerated() {
                h.draw(at: CGPoint(x: colX[idx], y: yPosition), withAttributes: [.font: boldBodyFont])
            }
            yPosition += 20

            // Table Rows
            for exp in group.activeExpenses {
                if yPosition > pageHeight - 60 {
                    context.beginPage()
                    yPosition = 40
                }

                let dateStr = exp.date.formatted(date: .numeric, time: .omitted)
                dateStr.draw(at: CGPoint(x: colX[0], y: yPosition), withAttributes: [.font: bodyFont])

                exp.title.draw(at: CGPoint(x: colX[1], y: yPosition), withAttributes: [.font: bodyFont])

                exp.category.displayName.draw(at: CGPoint(x: colX[2], y: yPosition), withAttributes: [.font: bodyFont])

                let amtStr = "\(exp.currency.symbol)\(String(format: "%.2f", MinorUnits.toMajorDouble(exp.amountMinorUnits, currency: exp.currency)))"
                amtStr.draw(at: CGPoint(x: colX[3], y: yPosition), withAttributes: [.font: boldBodyFont])

                yPosition += 20
            }
        }
    }
}
