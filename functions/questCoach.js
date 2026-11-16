
import { onCall, HttpsError } from "firebase-functions/v2/https";
import { getFirestore } from "firebase-admin/firestore";

// Read only the signed-in learner's challenge and progress.
async function readMyQuestState(uid) {
  const db = getFirestore();
  const challenge = await db.doc("challenges/today").get();

  const progress = await db.doc(
    `users/${uid}/progress/today`
  ).get();

  if (!challenge.exists) {
    throw new HttpsError("not-found", "Challenge not found.");
  }

  return {
    challenge: challenge.data(),
    progress: progress.exists ? progress.data() : null
  };
}

// Local mock for testing without an AI model.
export const askQuestCoach = onCall(async (request) => {

  // Check authentication.
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Sign in first.");
  }

  // Validate the question.
  const question = request.data?.question;

  if (
    typeof question !== "string" ||
    question.trim().length === 0 ||
    question.length > 300
  ) {
    throw new HttpsError(
      "invalid-argument",
      "Enter a question of 1 to 300 characters."
    );
  }

  // Get UID from verified Firebase Authentication.
  const uid = request.auth.uid;

  // Always read the learner's quest state first.
  let questState;

  try {
    questState = await readMyQuestState(uid);
  } catch (error) {
    if (error instanceof HttpsError) {
      throw error;
    }

    throw new HttpsError(
      "unavailable",
      "Unable to read quest state."
    );
  }

  // Mock hint based on the actual challenge.
  const prompt = questState.challenge.prompt;

  let reply;

  if (
    typeof prompt === "string" &&
    prompt.includes("StatelessWidget") &&
    prompt.includes("StatefulWidget")
  ) {
    reply =
      "Think about which widget can change its " +
      "appearance when its internal state changes.";
  } else {
    reply =
      "Read today's challenge carefully and " +
      "break it into smaller steps.";
  }

  console.log("readMyQuestState completed for signed-in learner");

  return { reply };
});
