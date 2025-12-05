// src/shared/interfaces/report.ts

import * as admin from 'firebase-admin';

/**
 * Defines the structure for a Report document in Firestore.
 */
export interface Report {
    userId: string;
    timestamp: admin.firestore.FieldValue;
    location: admin.firestore.GeoPoint;
    description: string;
    imageUrl: string;
    // Fields set by AI prioritization or Worker flow
    status: 'pending' | 'assigned' | 'in-progress' | 'resolved' | 'rejected';
    priority: number; // 1 (Low) to 5 (Critical)
    category: string; // e.g., 'Illegal Dumping', 'Broken Infrastructure'
    assignedToId?: string; // UID of the worker
    resolvedTimestamp?: admin.firestore.FieldValue;
}

/**
 * Defines the minimum data expected when a client submits a new report.
 */
export interface NewReportData {
    description: string;
    imageUrl: string;
    latitude: number;
    longitude: number;
}