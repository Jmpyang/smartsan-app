// src/shared/utils.ts

import * as functions from 'firebase-functions';

/**
 * Ensures that a required field exists in the data payload of a callable function.
 * Throws a specific HttpsError if the field is missing.
 * @param data The input data object from the client.
 * @param field The name of the required field (string).
 * @param endpointName The name of the endpoint for better logging.
 */
export function validateRequiredField(data: any, field: string, endpointName: string): void {
    if (!data || data[field] === undefined || data[field] === null) {
        functions.logger.error(`Validation failed for ${endpointName}: Missing required field '${field}'.`, data);
        throw new functions.https.HttpsError(
            'invalid-argument',
            `Missing required field: ${field}`
        );
    }
}

/**
 * Helper function to safely parse a value as an integer.
 * Returns null if the value is invalid.
 * @param value The input value (string or number).
 * @returns The parsed integer or null.
 */
export function safeParseInt(value: any): number | null {
    if (typeof value === 'number') {
        return Math.floor(value);
    }
    if (typeof value === 'string') {
        const parsed = parseInt(value, 10);
        if (!isNaN(parsed)) {
            return parsed;
        }
    }
    return null;
}

/**
 * Creates a standard log entry for successful function execution.
 * @param endpointName The name of the function that completed.
 * @param message A success message.
 * @param context The function's context (optional).
 */
export function logSuccess(endpointName: string, message: string, context?: functions.https.CallableContext): void {
    const user = context?.auth?.uid || 'anonymous';
    functions.logger.info(`[SUCCESS] ${endpointName} (${user}): ${message}`);
}