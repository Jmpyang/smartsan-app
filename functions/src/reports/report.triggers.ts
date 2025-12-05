// src/reports/report.triggers.ts

import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { Report } from '../shared/interfaces/report';
import { sendPushNotification } from '../shared/services/notification.service';

const db = admin.firestore();

/**
 * 1. onReportCreate: Notifies available workers when a new report is created, 
 * especially if it's high priority (Priority 4 or 5).
 * * NOTE: For production, this function would likely also trigger an automated 
 * assignment function to select the best worker.
 */
export const onReportCreate = functions.firestore
    .document('reports/{reportId}')
    .onCreate(async (snapshot, context) => {
    
    const report = snapshot.data() as Report;

    // Check if the report is high priority (e.g., Critical/Emergency)
    if (report.priority < 4) {
        functions.logger.info(`Report ${context.params.reportId} is low priority (${report.priority}). Skipping immediate notification.`);
        return null;
    }

    functions.logger.info(`High-priority report created: ${context.params.reportId}. Notifying workers.`);

    try {
        // 1. Find all available workers
        const availableWorkersSnapshot = await db.collection('users')
            .where('role', '==', 'worker')
            .where('isAvailable', '==', true)
            .get();

        if (availableWorkersSnapshot.empty) {
            functions.logger.warn('No available workers found to notify.');
            return null;
        }

        const reportTitle = `🚨 NEW CRITICAL TASK (${report.category})`;
        const reportBody = `Location: ${report.location.latitude.toFixed(2)}, ${report.location.longitude.toFixed(2)}. Description: ${report.description.substring(0, 50)}...`;

        // 2. Send notification to each available worker
        const notificationPromises: Promise<void>[] = [];

        availableWorkersSnapshot.docs.forEach(workerDoc => {
            const workerId = workerDoc.id;
            notificationPromises.push(
                sendPushNotification(workerId, reportTitle, reportBody)
            );
        });

        await Promise.all(notificationPromises);
        
        functions.logger.info(`Successfully notified ${notificationPromises.length} workers.`);

    } catch (error) {
        functions.logger.error(`Error processing report creation or sending notifications for ${context.params.reportId}:`, error);
        // The function should not throw, allowing the report write to complete
    }

    return null;
});

// ---

/**
 * 2. onReportUpdate: Triggers actions when a report document is updated, 
 * such as notifying the Community User when their report is resolved.
 */
export const onReportUpdate = functions.firestore
    .document('reports/{reportId}')
    .onUpdate(async (change, context) => {
        
    const before = change.before.data() as Report;
    const after = change.after.data() as Report;

    // A. Notification for Resolution
    // Check if the status has changed to 'resolved'
    if (before.status !== 'resolved' && after.status === 'resolved') {
        functions.logger.info(`Report ${context.params.reportId} resolved. Notifying community user.`);
        
        const communityUserId = after.userId;
        const notificationTitle = `✅ Report Resolved: ${after.category}`;
        const notificationBody = `Your sanitation issue has been successfully resolved by our team!`;
        
        // Notify the original community user
        await sendPushNotification(communityUserId, notificationTitle, notificationBody);
        
        // This is where you might also call a service to update the worker's performance score
        
    }
    
    // B. Notification for Assignment
    // Check if the assignedToId has just been set
    if (!before.assignedToId && after.assignedToId) {
        functions.logger.info(`Report ${context.params.reportId} assigned to ${after.assignedToId}.`);

        // Notify the community user that the task is now assigned to a worker
        await sendPushNotification(
            after.userId, 
            '🛠️ Your Report is in Progress!', 
            'A worker has been assigned and is heading to the location.'
        );
    }


    return null;
});