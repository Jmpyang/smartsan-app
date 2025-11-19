// src/analytics/analytics.model.ts

import * as admin from 'firebase-admin';

/**
 * Defines the structure for the overall summary metrics document
 * (Document ID: 'overall_summary' in the 'kpi_metrics' collection).
 */
export interface OverallKpiSummary {
    /** Total number of reports submitted since the app's launch. */
    totalReports: number;

    /** Total number of reports that have been marked 'resolved'. */
    totalResolved: number;

    /** The percentage of resolved reports out of the total submitted (e.g., 95.5). */
    resolutionRate: number;

    /** The average time taken from report submission to resolution (e.g., in hours). */
    avgCycleTime: number; 

    /** Timestamp of the last time this summary document was recalculated. */
    lastUpdated: admin.firestore.FieldValue;

    /** Total number of unique workers involved in resolving tasks. */
    activeWorkerCount: number;
}


/**
 * Defines the structure for a monthly aggregated report document
 * (Document ID: 'monthly_report_<YYYYMM>' in the 'kpi_metrics' collection).
 * Used for charting and trend analysis.
 */
export interface MonthlyReport {
    /** Year and month of the report (e.g., 202509). */
    period: number; 

    /** Total reports submitted in this specific month. */
    reportsSubmitted: number;

    /** Total reports resolved in this specific month. */
    reportsResolved: number;

    /** Breakdown of reports by category (e.g., { "Illegal Dumping": 45, "Broken Infrastructure": 12 }). */
    categoryCounts: { [key: string]: number };

    /** Average priority score for all reports submitted this month (e.g., 3.2). */
    avgPriority: number;
}