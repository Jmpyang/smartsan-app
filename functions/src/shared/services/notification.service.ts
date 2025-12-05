// src/shared/services/notification.service.ts

import * as admin from 'firebase-admin';
import * as functions from 'firebase-functions';

/**
 * Sends a push notification to a specific user using their FCM registration token.
 * This is crucial for notifying workers of new high-priority tasks.
 * * @param targetUserId The UID of the user to notify.
 * @param title The notification title.
 * @param body The notification message body.
 */
export async function sendPushNotification(targetUserId: string, title: string, body: string): Promise<void> {
    
    try {
        // 1. Get the FCM token for the target user from the 'users' collection
        const userDoc = await admin.firestore().collection('users').doc(targetUserId).get();
        const userToken = userDoc.data()?.fcmToken; // Assuming you store the token here

        if (!userToken) {
            functions.logger.warn(`Notification failed: No FCM token found for user ${targetUserId}`);
            return;
        }

        // 2. Construct the FCM message payload
        const message: admin.messaging.Message = {
            notification: {
                title: title,
                body: body,
            },
            data: {
                // Optional: custom data to handle navigation on the mobile app
                type: 'new_task',
                priority: 'high'
            },
            token: userToken,
        };

        // 3. Send the message
        const response = await admin.messaging().send(message);
        functions.logger.info(`Successfully sent message to ${targetUserId}: ${response}`);

    } catch (error) {
        functions.logger.error(`Error sending push notification to ${targetUserId}:`, error);
    }
}