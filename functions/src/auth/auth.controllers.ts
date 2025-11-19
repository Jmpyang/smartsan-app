// src/auth/auth.controller.ts

import * as admin from 'firebase-admin';
import * as functions from 'firebase-functions';
import { UserRole } from '../shared/interfaces/user';
import { validateRequiredField } from '../shared/utils';

const auth = admin.auth();
const db = admin.firestore();

/**
 * Assigns a specified role (Worker or Admin) to a user's Custom Claims
 * and updates their Firestore profile.
 * * @param targetUid The UID of the user whose role is being modified.
 * @param newRole The role to assign ('worker' or 'admin').
 * @param endpointName The name of the calling endpoint for logging.
 */
export async function assignUserRole(
    targetUid: string, 
    newRole: UserRole, 
    endpointName: string
): Promise<void> {
    
    // 1. Validate the role being assigned
    if (newRole !== 'worker' && newRole !== 'admin') {
        functions.logger.error(`[${endpointName}] Invalid role attempted: ${newRole} for UID ${targetUid}`);
        throw new functions.https.HttpsError(
            'invalid-argument',
            'Can only assign "worker" or "admin" roles via this function.'
        );
    }

    try {
        // 2. Set Custom Claim in Firebase Auth (for security rules)
        await auth.setCustomUserClaims(targetUid, { role: newRole });
        functions.logger.info(`[${endpointName}] Auth Custom Claim set to "${newRole}" for UID: ${targetUid}`);

        // 3. Update the user's role in the Firestore 'users' collection (for front-end display/data)
        await db.collection('users').doc(targetUid).set({
            role: newRole,
            // Ensure isAvailable is set for new workers
            isAvailable: (newRole === 'worker' ? true : admin.firestore.FieldValue.delete()), 
        }, { merge: true });

        functions.logger.info(`[${endpointName}] Firestore profile updated for UID: ${targetUid}`);

    } catch (error) {
        functions.logger.error(`[${endpointName}] Failed to set role for UID ${targetUid}:`, error);
        throw new functions.https.HttpsError(
            'internal',
            'Failed to update user role due to a server error.'
        );
    }
}