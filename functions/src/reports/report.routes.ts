// src/reports/report.routes.ts

import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { calculatePriority } from '../analytics/ai/prioritization';
import { NewReportData, Report } from '../shared/interfaces/report';

const db = admin.firestore();

/**
 * Callable function for clients (Mobile/Web) to submit a new sanitation report.
 * This is where the AI prioritization is executed.
 */
export const submitReport = functions.https.onCall(
    async (data: NewReportData, context) => {
    
    // 1. Authentication Check: Ensure a user is logged in
    if (!context.auth) {
        throw new functions.https.HttpsError('unauthenticated', 'The user must be logged in to submit a report.');
    }
    const userId = context.auth.uid;

    // 2. Input Validation (basic)
    if (!data.description || !data.imageUrl) {
        throw new functions.https.HttpsError('invalid-argument', 'Missing description or image URL.');
    }

    // 3. AI Prioritization: Call the Gemini logic
    const { priority, category } = await calculatePriority(data.description);
    functions.logger.info(`Report Priority: ${priority}, Category: ${category}`);

    // 4. Create the Firestore document
    const newReport: Report = {
        userId: userId,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        location: new admin.firestore.GeoPoint(data.latitude, data.longitude),
        description: data.description,
        imageUrl: data.imageUrl,
        status: 'pending', // Initial status
        priority: priority,
        category: category,
        // assignedToId will be null initially, or handled by a separate assignment function
    };

    // 5. Write to Firestore
    const reportRef = await db.collection('reports').add(newReport);

    return { 
        status: 'success', 
        message: 'Report submitted and prioritized successfully.', 
        reportId: reportRef.id 
    };
});