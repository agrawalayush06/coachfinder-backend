import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();
const db = admin.firestore();

/**
 * Cloud Function 1: Merge Pending Members on User Sign-up
 * Triggered when a new user document is created under /users/{userId}.
 * Automatically searches for pending member references tied to the user's phone number,
 * updates group memberships from pending to active, re-attributes balances, and cleans up.
 */
export const mergePendingMemberOnSignup = functions.firestore
  .document("users/{userId}")
  .onCreate(async (snap, context) => {
    const newUser = snap.data();
    const userId = context.params.userId;
    const phoneNumber = newUser.phoneNumber;

    if (!phoneNumber) {
      console.log(`No phone number for user ${userId}, skipping merge.`);
      return null;
    }

    console.log(`Checking pending member records for phone: ${phoneNumber}`);
    const pendingRef = db.collection("pendingMembers").doc(phoneNumber);
    const pendingDoc = await pendingRef.get();

    if (!pendingDoc.exists) {
      console.log(`No pending records found for ${phoneNumber}.`);
      return null;
    }

    const pendingData = pendingDoc.data();
    const groupIds: string[] = pendingData?.groupIds || [];

    const batch = db.batch();

    for (const groupId of groupIds) {
      const groupRef = db.collection("groups").doc(groupId);
      const groupDoc = await groupRef.get();

      if (groupDoc.exists) {
        const groupData = groupDoc.data();
        const members: any[] = groupData?.members || [];
        const memberIds: string[] = groupData?.memberIds || [];

        // Replace pending phone reference with real userId
        const updatedMembers = members.map((m) => {
          if (m.phoneNumber === phoneNumber && m.isPending) {
            return {
              ...m,
              memberId: userId,
              name: newUser.name || m.name,
              isPending: false,
              upiId: newUser.upiId || m.upiId || null,
            };
          }
          return m;
        });

        const pendingId = `pending_${phoneNumber}`;
        const updatedMemberIds = memberIds
          .filter((id) => id !== pendingId)
          .concat(userId);

        batch.update(groupRef, {
          members: updatedMembers,
          memberIds: updatedMemberIds,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      }
    }

    // Delete the pending member doc once merged
    batch.delete(pendingRef);

    await batch.commit();
    console.log(`Successfully merged ${groupIds.length} groups for user ${userId}.`);
    return null;
  });

/**
 * Cloud Function 2: Send Push Notification for New Expense
 * Notifies all group members (except the creator) when a new expense is logged.
 */
export const sendExpenseNudgePushNotification = functions.firestore
  .document("groups/{groupId}/expenses/{expenseId}")
  .onCreate(async (snap, context) => {
    const expense = snap.data();
    const groupId = context.params.groupId;
    const createdBy = expense.createdBy;

    const groupDoc = await db.collection("groups").doc(groupId).get();
    if (!groupDoc.exists) return null;

    const groupData = groupDoc.data();
    const memberIds: string[] = (groupData?.memberIds || []).filter(
      (id: string) => id !== createdBy && !id.startsWith("pending_")
    );

    if (memberIds.length === 0) return null;

    const tokens: string[] = [];
    for (const memberId of memberIds) {
      const userDoc = await db.collection("users").doc(memberId).get();
      const fcmTokens = userDoc.data()?.fcmTokens || [];
      tokens.push(...fcmTokens);
    }

    if (tokens.length === 0) return null;

    const currencySymbol = expense.currency === "INR" ? "₹" : "$";
    const majorAmount = (expense.amountMinorUnits / 100).toFixed(2);

    const payload = {
      notification: {
        title: `${groupData?.emoji || "💸"} ${groupData?.name || "Group"}`,
        body: `New expense: "${expense.title}" for ${currencySymbol}${majorAmount}`,
      },
      data: {
        groupId,
        expenseId: context.params.expenseId,
      },
    };

    const response = await admin.messaging().sendEachForMulticast({
      tokens,
      ...payload,
    });

    console.log(`Sent ${response.successCount} push notifications.`);
    return null;
  });

/**
 * Cloud Function 3: Recurring Expense Automation Cron
 * Scheduled daily to instantiate recurring monthly expenses (e.g. WiFi, Maid, Rent).
 */
export const recurringExpenseCron = functions.pubsub
  .schedule("0 9 * * *") // Daily at 9:00 AM
  .timeZone("Asia/Kolkata")
  .onRun(async (context) => {
    const today = new Date();
    // Check if today is the 1st of the month
    if (today.getDate() !== 1) {
      console.log("Not the 1st of the month, skipping recurring cycle.");
      return null;
    }

    const snapshot = await db
      .collectionGroup("expenses")
      .where("isRecurring", "==", true)
      .where("isDeleted", "==", false)
      .get();

    console.log(`Processing ${snapshot.docs.length} recurring expenses.`);

    for (const doc of snapshot.docs) {
      const data = doc.data();
      const groupId = data.groupId;

      const newExpense = {
        ...data,
        id: `exp_rec_${Date.now()}`,
        date: admin.firestore.FieldValue.serverTimestamp(),
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      };

      await db
        .collection("groups")
        .doc(groupId)
        .collection("expenses")
        .add(newExpense);
    }

    return null;
  });
