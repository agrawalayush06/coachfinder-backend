//
//  CoreMathTests.swift
//  SplitEase
//
//  Created for SplitEase.
//

import Foundation

public struct TestReport: Sendable {
    public let suiteName: String
    public let testName: String
    public let passed: Bool
    public let errorMessage: String?
}

public final class CoreMathTestSuite {
    public static func runAllTests() -> [TestReport] {
        var reports: [TestReport] = []

        func test(_ name: String, block: () throws -> Void) {
            do {
                try block()
                reports.append(TestReport(suiteName: "CoreMath", testName: name, passed: true, errorMessage: nil))
            } catch {
                reports.append(TestReport(suiteName: "CoreMath", testName: name, passed: false, errorMessage: "\(error)"))
            }
        }

        func assertEqual<T: Equatable>(_ actual: T, _ expected: T, _ msg: String = "", file: String = #file, line: Int = #line) throws {
            guard actual == expected else {
                throw NSError(domain: "TestFailure", code: 1, userInfo: [
                    NSLocalizedDescriptionKey: "Assertion failed at line \(line): Expected \(expected), got \(actual). \(msg)"
                ])
            }
        }

        func assertTrue(_ condition: Bool, _ msg: String = "", file: String = #file, line: Int = #line) throws {
            guard condition else {
                throw NSError(domain: "TestFailure", code: 1, userInfo: [
                    NSLocalizedDescriptionKey: "Condition false at line \(line). \(msg)"
                ])
            }
        }

        // --- MinorUnits Tests ---
        test("MinorUnits: Major to Minor conversion") {
            try assertEqual(MinorUnits.fromMajorDouble(12.50, currency: .inr), 1250)
            try assertEqual(MinorUnits.fromMajorDouble(0.05, currency: .inr), 5)
            try assertEqual(MinorUnits.fromMajorDouble(999.99, currency: .usd), 99999)
            try assertEqual(MinorUnits.fromMajorDouble(100.0, currency: .jpy), 100) // JPY multiplier = 1
        }

        test("MinorUnits: Minor to Major conversion") {
            try assertEqual(MinorUnits.toMajorDouble(1250, currency: .inr), 12.50)
            try assertEqual(MinorUnits.toMajorDouble(5, currency: .inr), 0.05)
            try assertEqual(MinorUnits.toMajorDouble(100, currency: .jpy), 100.0)
        }

        test("MinorUnits: String parsing with symbols and commas") {
            try assertEqual(MinorUnits.parse("1,250.75", currency: .inr), 125075)
            try assertEqual(MinorUnits.parse("₹ 500", currency: .inr), 50000)
            try assertEqual(MinorUnits.parse("$10.99", currency: .usd), 1099)
        }

        test("MinorUnits: Exact Penny/Paise distribution remainder preservation") {
            let parts3 = MinorUnits.distribute(amount: 100, parts: 3)
            try assertEqual(parts3, [34, 33, 33])
            try assertEqual(parts3.reduce(0, +), 100)

            let parts7 = MinorUnits.distribute(amount: 1000, parts: 7)
            try assertEqual(parts7.reduce(0, +), 1000)

            let parts4 = MinorUnits.distribute(amount: 7, parts: 4)
            try assertEqual(parts4, [2, 2, 2, 1])
            try assertEqual(parts4.reduce(0, +), 7)
        }

        test("MinorUnits: Proportional distribution with zero loss") {
            let weights: [Double] = [33.33, 33.33, 33.34]
            let shares = MinorUnits.distributeProportionally(amount: 100, weights: weights)
            try assertEqual(shares.reduce(0, +), 100)

            let ratioShares = MinorUnits.distributeProportionally(amount: 250, weights: [1.0, 2.0, 3.0])
            try assertEqual(ratioShares.reduce(0, +), 250)
        }

        // --- SplittingEngine Tests ---
        let pA = ParticipantShare(id: "pA", name: "Alice")
        let pB = ParticipantShare(id: "pB", name: "Bob")
        let pC = ParticipantShare(id: "pC", name: "Charlie")

        test("SplittingEngine: Equal split") {
            let results = try SplittingEngine.splitEqually(totalMinorUnits: 10000, participants: [pA, pB, pC])
            try assertEqual(results.count, 3)
            let total = results.map(\.amountMinorUnits).reduce(0, +)
            try assertEqual(total, 10000)
            try assertEqual(results[0].amountMinorUnits, 3334)
            try assertEqual(results[1].amountMinorUnits, 3333)
            try assertEqual(results[2].amountMinorUnits, 3333)
        }

        test("SplittingEngine: Exact amounts split") {
            let assignments = ["pA": Int64(4000), "pB": Int64(3500), "pC": Int64(2500)]
            let results = try SplittingEngine.splitExact(totalMinorUnits: 10000, assignments: assignments)
            try assertEqual(results.map(\.amountMinorUnits).reduce(0, +), 10000)

            // Mismatch should throw
            var didThrow = false
            do {
                _ = try SplittingEngine.splitExact(totalMinorUnits: 10000, assignments: ["pA": 5000, "pB": 4000])
            } catch {
                didThrow = true
            }
            try assertTrue(didThrow, "Should throw on exact mismatch")
        }

        test("SplittingEngine: Percentage split") {
            let pcts = ["pA": 50.0, "pB": 30.0, "pC": 20.0]
            let results = try SplittingEngine.splitByPercentage(totalMinorUnits: 10000, percentages: pcts)
            try assertEqual(results.map(\.amountMinorUnits).reduce(0, +), 10000)

            // Invalid percentage sum
            var didThrow = false
            do {
                _ = try SplittingEngine.splitByPercentage(totalMinorUnits: 10000, percentages: ["pA": 50.0, "pB": 20.0])
            } catch {
                didThrow = true
            }
            try assertTrue(didThrow, "Should throw on invalid percentage sum")
        }

        test("SplittingEngine: Shares split") {
            let shares = ["pA": 2, "pB": 1, "pC": 1]
            let results = try SplittingEngine.splitByShares(totalMinorUnits: 10000, shares: shares)
            try assertEqual(results.map(\.amountMinorUnits).reduce(0, +), 10000)
            // pA has 2/4 = 50% = 5000, pB & pC have 2500 each
            let map = Dictionary(uniqueKeysWithValues: results.map { ($0.participantId, $0.amountMinorUnits) })
            try assertEqual(map["pA"], 5000)
            try assertEqual(map["pB"], 2500)
            try assertEqual(map["pC"], 2500)
        }

        test("SplittingEngine: Itemized split with tax and tip") {
            let item1 = ItemizedBillItem(name: "Pizza", amountMinorUnits: 6000, assignedParticipantIds: ["pA", "pB"])
            let item2 = ItemizedBillItem(name: "Pasta", amountMinorUnits: 3000, assignedParticipantIds: ["pB", "pC"])
            let item3 = ItemizedBillItem(name: "Drinks", amountMinorUnits: 1000, assignedParticipantIds: ["pA"])

            let results = try SplittingEngine.splitItemized(
                items: [item1, item2, item3],
                participants: [pA, pB, pC],
                taxMinorUnits: 500,
                tipMinorUnits: 500
            )

            // Grand total must equal 6000 + 3000 + 1000 + 500 + 500 = 11000 exactly
            let total = results.map(\.amountMinorUnits).reduce(0, +)
            try assertEqual(total, 11000)
        }

        test("SplittingEngine: Adjustments split") {
            let adjustments = ["pA": Int64(500), "pB": Int64(-500), "pC": Int64(0)]
            let results = try SplittingEngine.splitByAdjustments(
                totalMinorUnits: 3000,
                participants: [pA, pB, pC],
                adjustments: adjustments
            )
            let total = results.map(\.amountMinorUnits).reduce(0, +)
            try assertEqual(total, 3000)

            let map = Dictionary(uniqueKeysWithValues: results.map { ($0.participantId, $0.amountMinorUnits) })
            try assertEqual(map["pA"], 1500) // 1000 + 500
            try assertEqual(map["pB"], 500)  // 1000 - 500
            try assertEqual(map["pC"], 1000) // 1000
        }

        // --- DebtSimplification Tests ---
        test("DebtSimplification: 3-person cycle simplifies to 0 transactions") {
            // A owes B 100, B owes C 100, C owes A 100
            let rawDebts = [
                RawPairwiseDebt(debtorId: "pA", creditorId: "pB", amountMinorUnits: 100),
                RawPairwiseDebt(debtorId: "pB", creditorId: "pC", amountMinorUnits: 100),
                RawPairwiseDebt(debtorId: "pC", creditorId: "pA", amountMinorUnits: 100)
            ]
            let transactions = DebtSimplification.simplifyPairwise(debts: rawDebts)
            try assertEqual(transactions.count, 0)
        }

        test("DebtSimplification: 3-person chain simplifies from 2 to 1 transaction") {
            // A owes B 100, B owes C 100 -> A should pay C 100 directly
            let rawDebts = [
                RawPairwiseDebt(debtorId: "pA", creditorId: "pB", amountMinorUnits: 100),
                RawPairwiseDebt(debtorId: "pB", creditorId: "pC", amountMinorUnits: 100)
            ]
            let transactions = DebtSimplification.simplifyPairwise(debts: rawDebts)
            try assertEqual(transactions.count, 1)
            try assertEqual(transactions[0].fromUserId, "pA")
            try assertEqual(transactions[0].toUserId, "pC")
            try assertEqual(transactions[0].amountMinorUnits, 100)
        }

        test("DebtSimplification: 4-person group expense settlement") {
            // Alice paid 400 for A, B, C, D (100 each)
            // Bob paid 200 for A, B (100 each)
            let exp1 = (payers: ["Alice": Int64(400)], splits: ["Alice": Int64(100), "Bob": Int64(100), "Charlie": Int64(100), "Dave": Int64(100)])
            let exp2 = (payers: ["Bob": Int64(200)], splits: ["Alice": Int64(100), "Bob": Int64(100)])

            let netBalances = DebtSimplification.computeNetBalances(expenses: [exp1, exp2])
            try assertEqual(netBalances["Alice"], 200)
            try assertEqual(netBalances["Bob"], 0)
            try assertEqual(netBalances["Charlie"], -100)
            try assertEqual(netBalances["Dave"], -100)

            let transactions = DebtSimplification.simplify(netBalances: netBalances)
            // Expect Charlie -> Alice 100, Dave -> Alice 100 (exactly 2 transactions)
            try assertEqual(transactions.count, 2)
            for t in transactions {
                try assertEqual(t.toUserId, "Alice")
                try assertEqual(t.amountMinorUnits, 100)
            }
        }

        test("DebtSimplification: Large group satisfies <= N-1 transactions bound") {
            var net: [String: Int64] = [:]
            // 8 members with arbitrary balanced nets
            net["u1"] = 1500
            net["u2"] = 2500
            net["u3"] = 1000
            net["u4"] = -1000
            net["u5"] = -1500
            net["u6"] = -1200
            net["u7"] = -800
            net["u8"] = -500 // Sum = +5000 and -5000 = 0

            let txs = DebtSimplification.simplify(netBalances: net)
            try assertTrue(txs.count <= 7, "Transactions \(txs.count) must be <= N - 1 (7)")
            // Verify all debts were settled exactly
            let totalSettled = txs.map(\.amountMinorUnits).reduce(0, +)
            try assertEqual(totalSettled, 5000)
        }

        return reports
    }
}

#if TEST_RUNNER
@main
struct TestRunner {
    static func main() {
        print("========================================")
        print("SPLITEASE PHASE 1: CORE MATH UNIT TESTS")
        print("========================================")
        let reports = CoreMathTestSuite.runAllTests()
        var passed = 0
        var failed = 0
        for r in reports {
            if r.passed {
                passed += 1
                print("  ✅ [PASS] \(r.testName)")
            } else {
                failed += 1
                let msg = r.errorMessage ?? ""
                print("  ❌ [FAIL] \(r.testName): \(msg)")
            }
        }
        print("----------------------------------------")
        print("TOTAL: \(reports.count) | PASSED: \(passed) | FAILED: \(failed)")
        print("========================================")
        if failed > 0 {
            exit(1)
        }
    }
}
#endif
