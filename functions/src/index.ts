import * as functions from "firebase-functions/v1";
import * as admin from "firebase-admin";

admin.initializeApp();
const db = admin.firestore();

/**
 * Syncs a public pet profile document in `publicPetProfiles/{petPublicId}`
 * whenever a pet document under `users/{userId}/pets/{petId}` is
 * created/updated/deleted.
 *
 * Owner name/phone come from Firebase Auth (userId == auth uid).
 *
 * Shape written:
 * publicPetProfiles/{petPublicId}:
 * {
 *   pet: { ...petData, id: petId },
 *   owner: { name, primaryPhone },
 *   lastSeen: { at, location },
 *   updatedAt: serverTimestamp()
 * }
 */
export const syncPublicPetProfileOnPetWrite = functions.firestore
  .document("users/{userId}/pets/{petId}")
  .onWrite(async (change, context) => {
    const {userId, petId} = context.params;

    const before = change.before;
    const after = change.after;

    // 1) Handle delete: remove public profile if pet was deleted
    if (!after.exists) {
      const beforeData =
        before.data() as FirebaseFirestore.DocumentData | undefined;
      const petPublicId = beforeData?.petPublicId as string | undefined;
      if (!petPublicId) {
        return;
      }
      await db.collection("publicPetProfiles").doc(petPublicId).delete();
      return;
    }

    // 2) Handle create/update: upsert public profile
    const petData = after.data() as FirebaseFirestore.DocumentData;
    const petPublicId = petData.petPublicId as string | undefined;

    // If pet has no public ID, nothing to sync
    if (!petPublicId) {
      return;
    }

    // Fetch owner from Firebase Auth (no users/{userId} doc needed)
    let owner: {name: string | null; primaryPhone: string | null} = {
      name: null,
      primaryPhone: null,
    };

    try {
      const userRecord = await admin.auth().getUser(userId);
      owner = {
        name: userRecord.displayName ?? null,
        primaryPhone: userRecord.phoneNumber ?? null,
      };
    } catch (e) {
      // If userRecord cannot be fetched, keep owner as nulls
      console.error(
        "Error fetching user record for public pet profile:",
        e,
      );
    }

    // Last-seen based on pet fields (you already added these to PetModel)
    const lastSeenAt = petData.lastSeenAt ?? null;
    const lastSeenLocation = petData.lastSeenLocation ?? null;

    const publicDoc = {
      pet: {
        // All pet fields as-is (timestamps, arrays, etc.)
        ...petData,
        // Ensure id is present so PetModel.fromJson can use it
        id: petId,
      },
      owner,
      lastSeen: {
        at: lastSeenAt,
        location: lastSeenLocation,
      },
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    await db
      .collection("publicPetProfiles")
      .doc(petPublicId)
      .set(publicDoc, {merge: true});
  });
