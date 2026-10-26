# SplitEase: Native iOS Expense Splitting & Debt Simplification

SplitEase is an offline-first, native iOS expense splitting application designed for high-performance financial tracking, multi-party debt minimization, and intelligent on-device receipt splitting. Built with **SwiftUI**, **SwiftData**, **Apple Vision**, and **Swift Charts**.

---

## 🌟 Key Features

1. **Precision Currency & Math Engine**:
   - Zero-floating-point rounding loss. All monetary amounts are computed and persisted in `Int64` minor units (cents/paise).
   - Pennies and paise remainders are preserved and apportioned deterministically using the Hare-Niemeyer / Largest Remainder algorithm.

2. **6 Advanced Splitting Modes**:
   - **Equally**: Split total bill evenly across all or selected participants with exact penny distribution.
   - **Exact Amounts**: Specify exact amounts each person owes with live difference validation.
   - **Percentages**: Allocate custom percentages with automatic integer conversion.
   - **By Shares**: Assign ratio weights (e.g., 2 shares for couples, 1 share for individuals).
   - **Itemized Bill**: Assign individual items from paper receipts, plus proportional tax and tip distribution based on personal consumption.
   - **Adjustments**: Equal base split with fixed $+/-$ dollar/rupee adjustments.

3. **Greedy Debt Simplification Algorithm**:
   - Minimizes the number of cash transactions in a group from $O(N^2)$ bilateral debts down to strictly $\le N - 1$ direct transactions using a bipartite net-balance greedy graph algorithm.

4. **Apple Vision Receipt OCR**:
   - On-device text recognition pipeline (`VNRecognizeTextRequest`).
   - Heuristically extracts line items, subtotals, taxes, and grand totals directly from camera snaps or photo library images.

5. **Natural Language Quick Add**:
   - On-device tokenizer that understands prompts like:
     `"Dinner 1200 with Ankit and Riya split equally"`
     and extracts amount, title, participants, and split strategy.

6. **Direct UPI Deep-Linking**:
   - One-tap settle-up linking directly to Indian UPI apps (**PhonePe**, **Google Pay**, **Paytm**) with pre-filled payee VPA, name, amount, and notes (`upi://pay?...`). Also supports cash recording.

7. **Pending Member Ledger & Auto-Merge**:
   - Add friends to groups and split expenses even if they have not installed the app yet, using their phone number.
   - When they register, Firebase Cloud Functions automatically merge their historical debts, groups, and activity into their new user account.

8. **Swift Charts Analytics & Export Suite**:
   - Monthly category breakdown donut charts with tap-to-inspect.
   - Spending comparison across groups and friends.
   - Native PDF report generation (`UIGraphicsPDFRenderer`) and tabular CSV export.

9. **Security & Biometrics**:
   - Optional Face ID / Touch ID / Optic ID biometric lock via `LocalAuthentication`.
   - Token persistence in iOS Keychain.

---

## 🏗️ Architecture & Folder Structure

```
CONTRO/
├── App/
│   └── CONTROApp.swift               # App Lifecycle & SwiftData ModelContainer
├── ContentView.swift                 # Root routing (Onboarding vs Main Tab)
├── MainTabView.swift                 # 5-Tab Root Navigation
│
├── Core/
│   ├── Math/
│   │   ├── MinorUnits.swift          # Int64 minor unit math & apportionment
│   │   ├── SplittingEngine.swift     # 6 split modes logic
│   │   └── DebtSimplification.swift  # Min-cash-flow graph algorithm
│   ├── OCR/
│   │   └── ReceiptScannerManager.swift # Apple Vision OCR
│   ├── NLP/
│   │   └── QuickAddParser.swift      # Natural language command tokenizer
│   ├── Security/
│   │   ├── BiometricAuthManager.swift # Face ID / Touch ID lock
│   │   └── KeychainStorage.swift     # Keychain persistence
│   └── Utilities/
│       ├── HapticManager.swift       # Haptic feedback
│       ├── PDFExporter.swift         # PDF summary generator
│       └── CSVExporter.swift         # CSV export generator
│
├── Models/
│   ├── Domain/                       # Pure Swift Enums & Structs
│   │   ├── Currency.swift            # INR, USD, EUR, GBP, JPY, etc.
│   │   ├── SplitType.swift           # equal, exact, %, shares, itemized, adjustment
│   │   ├── Category.swift            # 10 categories + keyword auto-classifier
│   │   ├── GroupRole.swift           # admin, member, group categories
│   │   ├── SettlementMethod.swift    # upi, cash, bankTransfer
│   │   └── ActivityType.swift        # expenseCreated, edited, deleted, settled
│   └── SwiftData/                    # Offline-first @Model Persistence
│       ├── SDUser.swift              # User profile
│       ├── SDGroup.swift             # Groups & members
│       ├── SDExpense.swift           # Expense entries & payers
│       ├── SDSplitItem.swift         # Individual allocations
│       ├── SDSettlement.swift        # Settle-up records
│       └── SDActivity.swift          # Audit logs
│
├── Features/
│   ├── Onboarding/                   # Intro Carousel, Phone Login, 6-digit OTP, Profile
│   ├── Home/                         # Balances hero card, shortcuts, friends ledger
│   ├── Groups/                       # Group list, group detail, simplified debts, trip summary
│   ├── Expenses/                     # Add expense, split configuration, receipt scanner, detail
│   ├── Activity/                     # Chronological audit feed
│   ├── Insights/                     # Swift Charts analytics
│   └── Profile/                      # Settings, Face ID toggle, Seed data generator
│
├── DesignSystem/
│   ├── Colors.swift                  # Semantic theme colors
│   ├── Components/                   # PrimaryButton, CurrencyTextField, UserAvatarView, StatusBadge
│   └── Modifiers/                    # Elevated card styling
│
├── Tests/
│   └── CoreMathTests.swift           # Unit test suite
│
├── functions/                        # Firebase TypeScript Cloud Functions
│   ├── package.json
│   ├── tsconfig.json
│   └── src/index.ts                  # Pending member merge & push notifications
│
└── firestore.rules                   # Production Firestore security rules
```

---

## 🧪 Running Unit Tests

### Option A: Standalone Swift CLI (Instant)
Run the complete Core Math test suite from terminal:

```bash
swiftc CONTRO/Models/Domain/Currency.swift \
       CONTRO/Models/Domain/SplitType.swift \
       CONTRO/Core/Math/MinorUnits.swift \
       CONTRO/Core/Math/SplittingEngine.swift \
       CONTRO/Core/Math/DebtSimplification.swift \
       CONTRO/Tests/CoreMathTests.swift \
       -o run_tests && ./run_tests
```

**Output**:
```
========================================
SPLITEASE PHASE 1: CORE MATH UNIT TESTS
========================================
  ✅ [PASS] MinorUnits: Major to Minor conversion
  ✅ [PASS] MinorUnits: Minor to Major conversion
  ✅ [PASS] MinorUnits: String parsing with symbols and commas
  ✅ [PASS] MinorUnits: Exact Penny/Paise distribution remainder preservation
  ✅ [PASS] MinorUnits: Proportional distribution with zero loss
  ✅ [PASS] SplittingEngine: Equal split
  ✅ [PASS] SplittingEngine: Exact amounts split
  ✅ [PASS] SplittingEngine: Percentage split
  ✅ [PASS] SplittingEngine: Shares split
  ✅ [PASS] SplittingEngine: Itemized split with tax and tip
  ✅ [PASS] SplittingEngine: Adjustments split
  ✅ [PASS] DebtSimplification: 3-person cycle simplifies to 0 transactions
  ✅ [PASS] DebtSimplification: 3-person chain simplifies from 2 to 1 transaction
  ✅ [PASS] DebtSimplification: 4-person group expense settlement
  ✅ [PASS] DebtSimplification: Large group satisfies <= N-1 transactions bound
----------------------------------------
TOTAL: 15 | PASSED: 15 | FAILED: 0
========================================
```

---

## 📱 Building & Running on Simulator

1. **Build the project via Xcode CLI**:
```bash
xcodebuild -project CONTRO.xcodeproj \
           -scheme CONTRO \
           -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
           build
```

2. **Launch on iPhone Simulator**:
```bash
xcrun simctl boot "iPhone 17 Pro"
xcrun simctl install booted <DerivedData_Path>/CONTRO.app
xcrun simctl launch booted com.CONTRO.CONTRO
```

---

## ⚡ Firebase Setup Guide

### 1. Enable Phone Authentication
1. Go to **Firebase Console** -> **Authentication** -> **Sign-in method** -> **Phone**.
2. Add Test Phone Numbers under "Phone numbers for testing":
   - Phone: `+91 98765 43210`
   - Verification Code: `123456`

### 2. Deploy Firestore Security Rules
```bash
firebase deploy --only firestore:rules
```

### 3. Deploy Cloud Functions
```bash
cd CONTRO/functions
npm install
npm run build
firebase deploy --only functions
```

---

## 🚀 Instant Demo Mode

The app comes with an automated seed loader (`SeedDataLoader.swift`) pre-populating:
- **Goa Vacation 2026 🏖️**: Beachfront Villa (₹24,000), Seafood Feast at Curlies (₹6,400), Scuba & Water Sports (₹8,000).
- **Flat 402 Indiranagar 🏠**: Airtel Fiber WiFi (₹1,499), Blinkit Groceries (₹2,100).
- **Friends Ledger**: Rohit Mehta (Pending), Riya Sharma, Ankit Verma.
- You can reload or reset seed data anytime from **Profile** -> **Developer / Demo Tools** -> **Populate Realistic Seed Data**.
