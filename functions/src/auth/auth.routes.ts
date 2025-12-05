// src/auth/auth.routes.ts

import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { assignUserRole } from './auth.controllers';
import { UserRole } from '../shared/interfaces/user';
import { validateRequiredField, logSuccess } from '../shared/utils';

const db = admin.firestore();

/**
 * Callable function for an ADMIN to assign the 'worker' or 'admin' role to another user.
 * * Data payload: { targetUid: string, role: 'worker' | 'admin' }
 */
export const assignRole = functions.https.onCall(
    async (data: { targetUid: string, role: UserRole }, context) => {
    
    const endpointName = 'assignRole';

    // 1. Authentication Check
    if (!context.auth) {
        throw new functions.https.HttpsError('unauthenticated', 'The user must be logged in.');
    }
    const requestingUid = context.auth.uid;

    // 2. Input Validation
    validateRequiredField(data, 'targetUid', endpointName);
    validateRequiredField(data, 'role', endpointName);
    
    const targetRole = data.role;

    // 3. Authorization Check: Ensure the requesting user is an Admin
    try {
        const requestingUserDoc = await db.collection('users').doc(requestingUid).get();
        const requestingRole = requestingUserDoc.data()?.role;

        if (requestingRole !== 'admin') {
            throw new functions.https.HttpsError('permission-denied', 'Only Admin users can assign roles.');
        }

    } catch (e) {
        functions.logger.error(`[${endpointName}] Error verifying admin role for UID ${requestingUid}:`, e);
        throw new functions.https.HttpsError('internal', 'Could not verify user permissions.');
    }

    // 4. Execute Role Assignment
    await assignUserRole(data.targetUid, targetRole, endpointName);
    
    logSuccess(endpointName, `Assigned role "${targetRole}" to UID ${data.targetUid}`, context);

    return { status: 'success', message: `Role successfully set to ${targetRole}.` };
});