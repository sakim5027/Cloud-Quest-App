
import { onCall, HttpsError } from "firebase-functions/v2/https";
import { initializeApp } from "firebase-admin/app";
import { FieldValue, getFirestore } from "firebase-admin/firestore";

initializeApp();

const db = getFirestore();

export const completeToday = onCall(async (request) => {

  // Check if the learner is signed in.
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Sign in first.");
  }

  // Only allow today's challenge.
  if (request.data?.challengeId !== "today") {
    throw new HttpsError("invalid-argument", "Unknown challenge.");
  }

  // Get the signed-in learner's ID.
  const uid = request.auth.uid;

  const progressRef = db.doc(`users/${uid}/progress/today`);

  // Use a transaction to prevent duplicate rewards.
  return db.runTransaction(async (transaction) => {

    const progress = await transaction.get(progressRef);

    // Already completed: do not award points again.
    if (progress.exists) {
      return {
        completed: true,
        points: progress.data().points,
        badgeId: progress.data().badgeId,
        alreadyCompleted: true
      };
    }

    // First completion: award 10 points and one badge.
    const reward = {
      completed: true,
      points: 10,
      badgeId: "first-quest",
      completedAt: FieldValue.serverTimestamp()
    };

    transaction.set(progressRef, reward);

    return {
      completed: true,
      points: reward.points,
      badgeId: reward.badgeId,
      alreadyCompleted: false
    };
  });
});
