//
//  ReceiptScannerView.swift
//  SplitEase
//
//  Created for SplitEase.
//

import SwiftUI
import PhotosUI

public struct ReceiptScannerView: View {
    @Environment(\.dismiss) private var dismiss
    let group: SDGroup
    var onItemsScanned: (([ScannedReceiptItem], Int64, Int64) -> Void)?

    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var isProcessing: Bool = false
    @State private var scannedResult: ScannedReceiptResult? = nil
    @State private var sampleBillLoaded: Bool = false

    public var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if let result = scannedResult {
                    // Results View
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                StatusBadge("OCR Detected", icon: "sparkles", color: .appPrimary)
                                Spacer()
                                Text("Total: \(group.currency.symbol)\(String(format: "%.2f", MinorUnits.toMajorDouble(result.totalMinorUnits, currency: group.currency)))")
                                    .font(.headline.weight(.heavy))
                            }

                            Text("Detected Items (\(result.items.count))")
                                .font(.subheadline.weight(.semibold))

                            VStack(spacing: 8) {
                                ForEach(result.items) { item in
                                    HStack {
                                        Text(item.name)
                                            .font(.system(size: 14, weight: .semibold))
                                        Spacer()
                                        Text("\(group.currency.symbol)\(String(format: "%.2f", MinorUnits.toMajorDouble(item.amountMinorUnits, currency: group.currency)))")
                                            .font(.system(size: 14, weight: .bold))
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                            .elevatedCard()

                            PrimaryButton("Apply to Expense Split", icon: "checkmark") {
                                onItemsScanned?(result.items, result.taxMinorUnits, result.totalMinorUnits)
                                dismiss()
                            }
                        }
                        .padding(16)
                    }
                } else {
                    // Empty / Action View
                    VStack(spacing: 24) {
                        Image(systemName: "text.viewfinder")
                            .font(.system(size: 72))
                            .foregroundColor(.appPrimary)

                        VStack(spacing: 6) {
                            Text("Scan Paper Receipt")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                            Text("Apple Vision OCR extracts line items, totals, and taxes directly on-device.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }

                        if isProcessing {
                            ProgressView("Analyzing receipt text...")
                                .padding()
                        } else {
                            VStack(spacing: 12) {
                                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                                    HStack {
                                        Image(systemName: "photo.on.rectangle")
                                        Text("Select Receipt from Photos")
                                    }
                                    .font(.system(size: 16, weight: .semibold))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 52)
                                    .background(Color.appPrimary)
                                    .foregroundColor(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                }

                                // Simulator quick test receipt button
                                Button(action: loadSampleReceipt) {
                                    HStack {
                                        Image(systemName: "doc.text.viewfinder")
                                        Text("Load Sample Restaurant Bill")
                                    }
                                    .font(.system(size: 15, weight: .semibold))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 52)
                                    .background(Color.surfaceSecondary)
                                    .foregroundColor(.primary)
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                }
                            }
                        }
                    }
                    .padding(24)
                }
            }
            .navigationTitle("Receipt Scanner")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .onChange(of: selectedPhotoItem) { _, newItem in
                Task {
                    guard let data = try? await newItem?.loadTransferable(type: Data.self),
                          let uiImage = UIImage(data: data) else { return }
                    isProcessing = true
                    scannedResult = try? await ReceiptScannerManager.recognizeText(from: uiImage)
                    isProcessing = false
                }
            }
        }
    }

    private func loadSampleReceipt() {
        HapticManager.impact(.medium)
        scannedResult = ScannedReceiptResult(
            items: [
                ScannedReceiptItem(name: "Woodfired Margherita Pizza", amountMinorUnits: 55000),
                ScannedReceiptItem(name: "Penne Arrabiata Pasta", amountMinorUnits: 42000),
                ScannedReceiptItem(name: "Garlic Bread with Cheese", amountMinorUnits: 22000),
                ScannedReceiptItem(name: "Fresh Lime Soda (x2)", amountMinorUnits: 18000),
                ScannedReceiptItem(name: "Tiramisu Classic", amountMinorUnits: 32000)
            ],
            taxMinorUnits: 8450,
            tipMinorUnits: 0,
            totalMinorUnits: 177450
        )
    }
}
