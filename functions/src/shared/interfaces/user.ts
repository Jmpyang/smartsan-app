import * as admin from 'firebase-admin';

/**
 * Defines the available roles in the SmartSan system.
 */
export type UserRole = 'community' | 'worker' | 'admin';

/**
 * Defines the structure for a User profile document in the 'users' collection.
 */
export interface UserProfile {
    uid: string;
    name: string;
    email: string;
    role: UserRole;
    isAvailable: boolean; // Relevant for Workers
    teamId?: string;
    lastActive?: admin.firestore.FieldValue;
}