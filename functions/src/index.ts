// src/index.ts

import * as admin from 'firebase-admin';

// Initialize the Firebase Admin SDK once for all functions
// The Admin SDK automatically finds credentials when running in Cloud Functions
admin.initializeApp();

// --- 1. REPORTS Functions ---
export { submitReport } from './reports/report.routes';

// --- 2. WORKER Functions ---
export { updateTaskStatus } from './workers/worker.service';

// --- 3. ANALYTICS Functions ---
export { nightlyKpiUpdate } from './analytics/analytics.scheduled';

// --- (You would add functions for User Roles/Auth and other features here) ---
export { 
    onReportCreate,
    onReportUpdate 
} from './reports/report.triggers';

export { assignRole } from './auth/auth.routes';

