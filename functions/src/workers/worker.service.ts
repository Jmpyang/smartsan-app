// src/workers/worker.service.ts

import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const db = admin.firestore();

/**
 * Callable function for Workers to update the status of an assigned task.
 * @param taskId The ID of the report document.
 * @param newStatus The new status: 'in-progress' or 'resolved'.
 */
export const updateTaskStatus = functions.https.onCall(
    async (data: { taskId: string, newStatus: 'in-progress' | 'resolved' }, context) => {
    
    // 1. Authentication and Authorization Check
    if (!context.auth) {
        throw new functions.https.HttpsError('unauthenticated', 'Worker must be logged in.');
    }
    const workerId = context.auth.uid;

    if (!data.taskId || (data.newStatus !== 'in-progress' && data.newStatus !== 'resolved')) {
        throw new functions.https.HttpsError('invalid-argument', 'Invalid task ID or status.');
    }

    const reportRef = db.collection('reports').doc(data.taskId);
    const reportSnapshot = await reportRef.get();

    if (!reportSnapshot.exists) {
        throw new functions.https.HttpsError('not-found', 'Report not found.');
    }

    const report = reportSnapshot.data();

    // Crucial Security Check: Ensure the worker is the one assigned to the task
    if (report && report.assignedToId !== workerId) {
        throw new functions.https.HttpsError('permission-denied', 'You are not assigned to this task.');
    }

    // 2. Update the Report document
    const updateData: { status: string, resolvedTimestamp?: admin.firestore.FieldValue } = {
        status: data.newStatus,
    };

    if (data.newStatus === 'resolved') {
        updateData.resolvedTimestamp = admin.firestore.FieldValue.serverTimestamp();
    }

    await reportRef.update(updateData);

    return { status: 'success', message: `Task ${data.newStatus} successfully.` };
});