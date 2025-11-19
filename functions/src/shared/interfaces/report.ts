import * as admin from 'firebase-admin';

/**
 * Defines the complete structure for a Report document in Firestore.
 */
export interface Report {
    userId: string;
    timestamp: admin.firestore.FieldValue;
    location: admin.firestore.GeoPoint;
    description: string;
    imageUrl: string;
    
    // Fields set by AI prioritization or Worker flow
    status: 'pending' | 'assigned' | 'in-progress' | 'resolved' | 'rejected';
    priority: number; // 1 (Low) to 5 (Critical), set by Gemini AI
    category: string; // e.g., 'Illegal Dumping', 'Broken Infrastructure', set by Gemini AI
    
    assignedToId?: string; // UID of the worker handling the task
    resolvedTimestamp?: admin.firestore.FieldValue;
    workerNotes?: string; // Notes added by the worker upon resolution
}

/**
 * Defines the minimum data expected when a client submits a new report.
 * Used for input validation in the report.routes.ts.
 */
export interface NewReportData {
    description: string;
    imageUrl: string;
    latitude: number;
    longitude: number;
}