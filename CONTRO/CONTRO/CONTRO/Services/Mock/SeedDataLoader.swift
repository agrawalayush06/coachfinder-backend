//
//  SeedDataLoader.swift
//  SplitEase
//
//  Created for SplitEase.
//

import Foundation
import SwiftData

public struct SeedDataLoader {
    public static func loadSampleData(modelContext: ModelContext, forceReload: Bool = false) {
        if forceReload {
            try? modelContext.delete(model: SDExpense.self)
            try? modelContext.delete(model: SDSplitItem.self)
            try? modelContext.delete(model: SDSettlement.self)
            try? modelContext.delete(model: SDActivity.self)
            try? modelContext.delete(model: SDGroup.self)
            try? modelContext.delete(model: SDUser.self)
        } else {
            // Clear existing demo data to avoid duplicates
            let groupDescriptor = FetchDescriptor<SDGroup>()
            if let existing = try? modelContext.fetch(groupDescriptor), !existing.isEmpty {
                return // Already seeded
            }
        }

        let currentUserId = UserDefaults.standard.string(forKey: "splitease_user_id") ?? "usr_ayush"
        let currentUserName = UserDefaults.standard.string(forKey: "splitease_user_name") ?? "Ayush Kumar"

        // Persist session state so user is logged in
        UserDefaults.standard.set(true, forKey: "splitease_is_logged_in")
        UserDefaults.standard.set(currentUserId, forKey: "splitease_user_id")
        UserDefaults.standard.set(currentUserName, forKey: "splitease_user_name")
        UserDefaults.standard.set("+919876543210", forKey: "splitease_phone")
        UserDefaults.standard.set("INR", forKey: "splitease_currency")
        UserDefaults.standard.set("ayush@oksbi", forKey: "splitease_upi_id")

        // 1. Current User
        let currentUser = SDUser(
            id: currentUserId,
            phoneNumber: "+919876543210",
            name: currentUserName,
            defaultCurrencyCode: "INR",
            upiId: "ayush@oksbi",
            isCurrentUser: true
        )
        modelContext.insert(currentUser)

        // Other Friends
        let riya = GroupMember(id: "usr_riya", name: "Riya Sharma", phoneNumber: "+919888877776", role: "admin", upiId: "riya@okhdfcbank")
        let ankit = GroupMember(id: "usr_ankit", name: "Ankit Verma", phoneNumber: "+919123456789", role: "member", isPending: false, upiId: "ankit@paytm")
        let rohit = GroupMember(id: "usr_rohit", name: "Rohit Mehta", phoneNumber: "+919555544443", role: "member", isPending: true) // Pending member!
        let priya = GroupMember(id: "usr_priya", name: "Priya Patel", phoneNumber: "+919666633332", role: "member", upiId: "priya@axl")

        let selfMember = GroupMember(id: currentUserId, name: currentUserName, phoneNumber: "+919876543210", role: "admin", upiId: "ayush@oksbi")

        // 2. Group 1: Goa Vacation 2026 (Trip)
        let goaGroup = SDGroup(
            id: "grp_goa_2026",
            name: "Goa Vacation 🏖️",
            emoji: "🏖️",
            categoryRaw: GroupCategory.trip.rawValue,
            defaultCurrencyCode: "INR",
            createdByUserId: currentUserId,
            simplifyDebts: true,
            members: [selfMember, riya, ankit, rohit]
        )
        modelContext.insert(goaGroup)

        // Goa Expenses
        // Expense 1: Private Beach Villa (₹24,000 paid by Ayush, split equally 4 ways)
        let expVilla = SDExpense(
            id: "exp_villa",
            groupId: goaGroup.id,
            title: "Beachfront Villa Booking",
            amountMinorUnits: 2400000,
            currencyCode: "INR",
            categoryRaw: ExpenseCategory.accommodation.rawValue,
            date: Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date(),
            notes: "3 nights at Anjuna Beach Villa",
            payers: [ExpensePayer(memberId: currentUserId, amountMinorUnits: 2400000)],
            splitTypeRaw: SplitType.equal.rawValue,
            createdByUserId: currentUserId
        )
        expVilla.group = goaGroup
        modelContext.insert(expVilla)

        let villaSplits = [currentUserId, "usr_riya", "usr_ankit", "usr_rohit"].map { mId in
            let item = SDSplitItem(
                participantId: mId,
                participantName: mId == currentUserId ? currentUserName : (mId == "usr_riya" ? "Riya Sharma" : (mId == "usr_ankit" ? "Ankit Verma" : "Rohit Mehta")),
                amountMinorUnits: 600000,
                percentage: 25.0,
                detail: "1/4 share"
            )
            item.expense = expVilla
            return item
        }
        for s in villaSplits { modelContext.insert(s) }
        expVilla.splits = villaSplits

        // Expense 2: Seafood Feast (₹6,400 paid by Riya, itemized)
        let expDinner = SDExpense(
            id: "exp_dinner",
            groupId: goaGroup.id,
            title: "Seafood Feast at Curlies",
            amountMinorUnits: 640000,
            currencyCode: "INR",
            categoryRaw: ExpenseCategory.foodAndDining.rawValue,
            date: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(),
            notes: "Lobster, Tiger prawns, cocktails",
            payers: [ExpensePayer(memberId: "usr_riya", amountMinorUnits: 640000)],
            splitTypeRaw: SplitType.exact.rawValue,
            createdByUserId: "usr_riya"
        )
        expDinner.group = goaGroup
        modelContext.insert(expDinner)

        let dinnerSplits = [
            SDSplitItem(participantId: currentUserId, participantName: currentUserName, amountMinorUnits: 180000, detail: "Cocktails & Prawns"),
            SDSplitItem(participantId: "usr_riya", participantName: "Riya Sharma", amountMinorUnits: 160000, detail: "Fish Curry"),
            SDSplitItem(participantId: "usr_ankit", participantName: "Ankit Verma", amountMinorUnits: 150000, detail: "Lobster"),
            SDSplitItem(participantId: "usr_rohit", participantName: "Rohit Mehta", amountMinorUnits: 150000, detail: "Vegetarian Platter")
        ]
        for s in dinnerSplits {
            s.expense = expDinner
            modelContext.insert(s)
        }
        expDinner.splits = dinnerSplits

        // Expense 3: Scuba & Water Sports (₹8,000 paid by Ankit)
        let expScuba = SDExpense(
            id: "exp_scuba",
            groupId: goaGroup.id,
            title: "Scuba Diving & Jet Ski",
            amountMinorUnits: 800000,
            currencyCode: "INR",
            categoryRaw: ExpenseCategory.entertainment.rawValue,
            date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
            notes: "Grand Island Scuba package",
            payers: [ExpensePayer(memberId: "usr_ankit", amountMinorUnits: 800000)],
            splitTypeRaw: SplitType.equal.rawValue,
            createdByUserId: "usr_ankit"
        )
        expScuba.group = goaGroup
        modelContext.insert(expScuba)

        let scubaSplits = [currentUserId, "usr_riya", "usr_ankit", "usr_rohit"].map { mId in
            let item = SDSplitItem(
                participantId: mId,
                participantName: mId == currentUserId ? currentUserName : (mId == "usr_riya" ? "Riya Sharma" : (mId == "usr_ankit" ? "Ankit Verma" : "Rohit Mehta")),
                amountMinorUnits: 200000,
                percentage: 25.0
            )
            item.expense = expScuba
            return item
        }
        for s in scubaSplits { modelContext.insert(s) }
        expScuba.splits = scubaSplits

        // 3. Group 2: Flat 402 - Indiranagar (Flatmates)
        let flatGroup = SDGroup(
            id: "grp_flat_402",
            name: "Flat 402 Indiranagar 🏠",
            emoji: "🏠",
            categoryRaw: GroupCategory.flatmates.rawValue,
            defaultCurrencyCode: "INR",
            createdByUserId: currentUserId,
            simplifyDebts: true,
            members: [selfMember, ankit, priya]
        )
        modelContext.insert(flatGroup)

        // Flat Expense: High Speed WiFi (₹1,499 paid by Ayush)
        let expWifi = SDExpense(
            id: "exp_wifi",
            groupId: flatGroup.id,
            title: "Airtel Fiber 300 Mbps",
            amountMinorUnits: 149900,
            currencyCode: "INR",
            categoryRaw: ExpenseCategory.utilities.rawValue,
            date: Calendar.current.date(byAdding: .day, value: -5, to: Date()) ?? Date(),
            notes: "Monthly internet bill",
            payers: [ExpensePayer(memberId: currentUserId, amountMinorUnits: 149900)],
            splitTypeRaw: SplitType.equal.rawValue,
            isRecurring: true,
            createdByUserId: currentUserId
        )
        expWifi.group = flatGroup
        modelContext.insert(expWifi)

        let wifiSplits = [
            SDSplitItem(participantId: currentUserId, participantName: currentUserName, amountMinorUnits: 50000),
            SDSplitItem(participantId: "usr_ankit", participantName: "Ankit Verma", amountMinorUnits: 50000),
            SDSplitItem(participantId: "usr_priya", participantName: "Priya Patel", amountMinorUnits: 49900)
        ]
        for s in wifiSplits {
            s.expense = expWifi
            modelContext.insert(s)
        }
        expWifi.splits = wifiSplits

        // Flat Expense: Blinkit Groceries (₹2,100 paid by Priya)
        let expGroceries = SDExpense(
            id: "exp_groceries",
            groupId: flatGroup.id,
            title: "Blinkit House Supplies",
            amountMinorUnits: 210000,
            currencyCode: "INR",
            categoryRaw: ExpenseCategory.groceries.rawValue,
            date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
            notes: "Cooking oil, spices, detergent, milk",
            payers: [ExpensePayer(memberId: "usr_priya", amountMinorUnits: 210000)],
            splitTypeRaw: SplitType.equal.rawValue,
            createdByUserId: "usr_priya"
        )
        expGroceries.group = flatGroup
        modelContext.insert(expGroceries)

        let grocerySplits = [
            SDSplitItem(participantId: currentUserId, participantName: currentUserName, amountMinorUnits: 70000),
            SDSplitItem(participantId: "usr_ankit", participantName: "Ankit Verma", amountMinorUnits: 70000),
            SDSplitItem(participantId: "usr_priya", participantName: "Priya Patel", amountMinorUnits: 70000)
        ]
        for s in grocerySplits {
            s.expense = expGroceries
            modelContext.insert(s)
        }
        expGroceries.splits = grocerySplits

        // 4. Activity Logs
        let act1 = SDActivity(
            groupId: goaGroup.id,
            actorId: currentUserId,
            actorName: currentUserName,
            typeRaw: ActivityType.expenseCreated.rawValue,
            targetExpenseTitle: "Beachfront Villa Booking",
            amountMinorUnits: 2400000,
            message: "\(currentUserName) added \'Beachfront Villa Booking\' (₹24,000)"
        )
        act1.group = goaGroup
        modelContext.insert(act1)

        let act2 = SDActivity(
            groupId: goaGroup.id,
            actorId: "usr_riya",
            actorName: "Riya Sharma",
            typeRaw: ActivityType.expenseCreated.rawValue,
            targetExpenseTitle: "Seafood Feast at Curlies",
            amountMinorUnits: 640000,
            message: "Riya Sharma added \'Seafood Feast at Curlies\' (₹6,400)"
        )
        act2.group = goaGroup
        modelContext.insert(act2)

        let act3 = SDActivity(
            groupId: flatGroup.id,
            actorId: "usr_priya",
            actorName: "Priya Patel",
            typeRaw: ActivityType.expenseCreated.rawValue,
            targetExpenseTitle: "Blinkit House Supplies",
            amountMinorUnits: 210000,
            message: "Priya Patel added \'Blinkit House Supplies\' (₹2,100)"
        )
        act3.group = flatGroup
        modelContext.insert(act3)

        try? modelContext.save()
        print("Seed data successfully loaded!")
    }
}
