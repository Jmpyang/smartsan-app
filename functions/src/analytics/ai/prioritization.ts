// src/analytics/ai/prioritization.ts

import { GoogleGenAI } from "@google/genai";
import * as functions from 'firebase-functions';

// Initialize the Gemini AI client using the securely configured API key
const ai = new GoogleGenAI(functions.config().ai.gemini_key);

/**
 * Uses Gemini 2.5 Flash to analyze report description and assign priority and category.
 * @param description The user-submitted text description of the issue.
 * @returns An object containing the priority (1-5) and category.
 */
export async function calculatePriority(description: string): Promise<{ priority: number, category: string }> {
    
    // Define the list of expected categories for the AI to choose from
    const categories = ['Waste Collection', 'Illegal Dumping', 'Broken Infrastructure', 'Emergency Cleanup', 'Other'];

    const prompt = `
        You are an expert sanitation dispatcher AI. Analyze the following report and strictly classify it.
        
        Report Description: "${description}"

        Rules:
        1. **Priority (1-5):** 5 is Critical (e.g., immediate health hazard), 1 is Low (e.g., minor litter).
        2. **Category:** Must be one of: ${categories.join(', ')}.
        3. **Output Format:** Provide a single JSON object.
    `;

    try {
        const response = await ai.models.generateContent({
            model: "gemini-2.5-flash",
            contents: [prompt],
            config: {
                // Force the output to be a JSON object for easy parsing
                responseMimeType: "application/json",
                responseSchema: {
                    type: "object",
                    properties: {
                        priority: { type: "number", description: "The priority score from 1 to 5." },
                        category: { type: "string", description: "The primary issue category." }
                    }
                }
            }
        });

        const rawText = typeof response?.text === 'string' ? response.text : '';
        if (!rawText) {
            functions.logger.warn('Empty or undefined AI response text. Defaulting.');
            return { priority: 1, category: 'Other' };
        }
        const jsonString = rawText.trim();
        const result = JSON.parse(jsonString);

        // Simple validation to ensure the AI followed the rules
        if (typeof result.priority !== 'number' || !categories.includes(result.category)) {
            functions.logger.warn(`AI output validation failed: ${jsonString}. Defaulting.`);
            return { priority: 2, category: 'Other' };
        }

        return {
            priority: Math.min(5, Math.max(1, Math.round(result.priority))), // Clamp priority between 1 and 5
            category: result.category
        };

    } catch (error) {
        functions.logger.error("Gemini API call failed:", error);
        // Fallback in case of API failure
        return { priority: 1, category: 'Other' };
    }
}