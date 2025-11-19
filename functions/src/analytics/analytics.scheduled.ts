// src/analytics/analytics.scheduled.ts

import * as functionsV2 from 'firebase-functions/v2/scheduler';
import * as admin from 'firebase-admin';
import * as functions from 'firebase-functions';

const db = admin.firestore();

/**
 * Runs daily at midnight (00:00) to aggregate resolved reports and update KPI metrics.
 * The schedule is defined using Crontab syntax: '0 0 * * *'
 *
 * NOTE: This requires the project to be on the Blaze pricing plan.
 */
export const nightlyKpiUpdate = functionsV2.onSchedule('0 0 * * *', async (context) => {
    
    functions.logger.info("Starting nightly KPI aggregation...");

    // 1. Calculate time frame for today's resolved reports (to avoid re-calculating everything)
    const now = new Date();
    const startOfToday = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    
    // 2. Query reports resolved in the last day (or use a simple aggregation query)
    const resolvedReportsSnapshot = await db.collection('reports')
        .where('status', '==', 'resolved')
        .get(); // Simpler query for demonstration

    // 3. Simple Aggregation (Calculating total and resolution rate)
    const totalReportsSnapshot = await db.collection('reports').get();
    const totalReports = totalReportsSnapshot.size;
    const totalResolved = resolvedReportsSnapshot.size;
    const resolutionRate = totalReports > 0 ? (totalResolved / totalReports) * 100 : 0;

    // 4. Update the centralized KPI metrics document
    await db.collection('kpi_metrics').doc('overall_summary').set({
        totalReports: totalReports,
        totalResolved: totalResolved,
        resolutionRate: parseFloat(resolutionRate.toFixed(2)),
        lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
    }, { merge: true }); // Use merge to prevent overwriting other fields

    functions.logger.info(`KPI update complete. Total Reports: ${totalReports}, Resolution Rate: ${resolutionRate.toFixed(2)}%`);
});