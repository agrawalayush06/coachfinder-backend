//
//  SettleUpView.swift
//  SplitEase
//
//  Created for SplitEase.
//

import SwiftUI
import SwiftData

public struct SettleUpView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let friend: FriendBalanceSummary
    let groups: [SDGroup]

    @State private var settleAmountMinorUnits: Int64 = 0
    @State private var settlementMethod: SettlementMethod = .upi
    @State private var selectedGroupId: String = ""
    @State private var isRecorded: Bool = false

    public var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Settle Header Card
                VStack(spacing: 12) {
                    UserAvatarView(name: friend.name, size: 72)

                    Text("Settle with \(friend.name)")
                        .font(.system(size: 22, weight: .bold, design: .rounded))

                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text(friend.currency.symbol)
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(.secondary)
                        Text(String(format: "%.2f", MinorUnits.toMajorDouble(settleAmountMinorUnits, currency: friend.currency)))
                            .font(.system(size: 38, weight: .heavy, design: .rounded))
                            .foregroundColor(.primary)
                    }
                }
                .frame(maxWidth: .infinity)
                .elevatedCard()

                if groups.count > 1 {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Apply to Group")
                            .font(.headline)
                        Picker("Group", selection: $selectedGroupId) {
                            ForEach(groups) { g in
                                Text("\(g.emoji) \(g.name)").tag(g.id)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(8)
                        .background(Color.surfaceSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .elevatedCard()
                }

                // Method Picker
                VStack(alignment: .leading, spacing: 12) {
                    Text("Payment Method")
                        .font(.headline)

                    ForEach(SettlementMethod.allCases) { method in
                        Button(action: {
                            HapticManager.selection()
                            settlementMethod = method
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: method.systemImage)
                                    .font(.system(size: 20))
                                    .foregroundColor(.appPrimary)
                                    .frame(width: 36, height: 36)
                                    .background(Color.appPrimary.opacity(0.12))
                                    .clipShape(Circle())

                                Text(method.displayName)
                                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                                    .foregroundColor(.primary)

                                Spacer()

                                Image(systemName: settlementMethod == method ? "checkmark.circle.fill" : "circle")
                                    .font(.system(size: 20))
                                    .foregroundColor(settlementMethod == method ? .appPrimary : .secondary)
                            }
                            .padding(.vertical, 8)
                        }
                    }
                }
                .elevatedCard()

                if settlementMethod == .upi {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "bolt.fill")
                                .foregroundColor(.orange)
                            Text("One-Tap UPI Deep Link")
                                .font(.subheadline.weight(.bold))
                        }
                        Text("Opens PhonePe, Google Pay, or Paytm directly with the amount pre-filled.")
                            .font(.caption2)
                            .foregroundColor(.secondary)

                        Button(action: {
                            openUPILink()
                        }) {
                            HStack {
                                Image(systemName: "arrow.up.right.square.fill")
                                Text("Pay via UPI App")
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color.appPrimary.opacity(0.15))
                            .foregroundColor(.appPrimary)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                    .elevatedCard()
                }

                Spacer()

                PrimaryButton("Record Settlement", icon: "checkmark.circle.fill", variant: .primary) {
                    recordSettlement()
                }
                .padding(.bottom, 24)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .background(Color.surfaceSecondary.ignoresSafeArea())
            .navigationTitle("Settle Up")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onAppear {
                self.settleAmountMinorUnits = abs(friend.netMinorUnits)
                self.selectedGroupId = groups.first?.id ?? ""
            }
        }
    }

    private func openUPILink() {
        let currentUserName = UserDefaults.standard.string(forKey: "splitease_user_name") ?? "You"
        let upiId = friend.upiId ?? "ayush@oksbi"
        let amount = String(format: "%.2f", MinorUnits.toMajorDouble(settleAmountMinorUnits, currency: friend.currency))
        let note = "SplitEase Settlement"

        let urlString = "upi://pay?pa=\(upiId)&pn=\(friend.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&am=\(amount)&cu=INR&tn=\(note.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"

        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
        HapticManager.notification(.success)
    }

    private func recordSettlement() {
        let currentUserId = UserDefaults.standard.string(forKey: "splitease_user_id") ?? "usr_default"
        let currentUserName = UserDefaults.standard.string(forKey: "splitease_user_name") ?? "You"

        let targetGroup = groups.first(where: { $0.id == selectedGroupId }) ?? groups.first

        let stl = SDSettlement(
            groupId: targetGroup?.id ?? "grp_global",
            payerId: friend.netMinorUnits < 0 ? currentUserId : friend.memberId,
            payerName: friend.netMinorUnits < 0 ? currentUserName : friend.name,
            receiverId: friend.netMinorUnits < 0 ? friend.memberId : currentUserId,
            receiverName: friend.netMinorUnits < 0 ? friend.name : currentUserName,
            amountMinorUnits: settleAmountMinorUnits,
            currencyCode: friend.currency.rawValue,
            methodRaw: settlementMethod.rawValue,
            statusRaw: SettlementStatus.confirmed.rawValue
        )
        stl.group = targetGroup
        modelContext.insert(stl)
        if let targetGroup = targetGroup {
            if !targetGroup.settlements.contains(where: { $0.id == stl.id }) {
                targetGroup.settlements.append(stl)
            }
        }

        // Activity log
        let act = SDActivity(
            groupId: targetGroup?.id ?? "grp_global",
            actorId: currentUserId,
            actorName: currentUserName,
            typeRaw: ActivityType.settled.rawValue,
            amountMinorUnits: settleAmountMinorUnits,
            message: "\(stl.payerName) paid \(stl.receiverName) \(friend.currency.symbol)\(String(format: "%.2f", MinorUnits.toMajorDouble(settleAmountMinorUnits, currency: friend.currency)))"
        )
        act.group = targetGroup
        modelContext.insert(act)
        targetGroup?.updatedAt = Date()
        CloudSyncEngine.shared.markPendingChange()

        try? modelContext.save()
        DataRefreshCoordinator.notifyDataChanged()
        HapticManager.notification(.success)
        dismiss()
    }
}
