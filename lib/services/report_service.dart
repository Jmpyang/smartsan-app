// lib/services/report_service.dart

import 'package:cloud_functions/cloud_functions.dart';

class ReportService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  // The submitReport function must now accept all the new parameters
  Future<Map<String, dynamic>> submitReport({
    required String description, 
    required String category, // 👈 ADDED
    required String priority, // 👈 ADDED
    required String imageUrl, 
    required String locationString, // 👈 ADDED
    required double lat, 
    required double lng,
  }) async {
    try {
      // The function name MUST match the export name in functions/src/index.ts
      final HttpsCallable callable = _functions.httpsCallable('submitReport'); 

      final response = await callable.call(<String, dynamic>{
        'description': description,
        'category': category,      // Pass category
        'priority': priority,      // Pass priority
        'imageUrl': imageUrl,
        'locationString': locationString, // Pass location string
        'latitude': lat,
        'longitude': lng,
      });

      // The backend returns { status: 'success', reportId: '...' }
      return response.data; 
      
    } on FirebaseFunctionsException catch (e) {
      // Handle HttpsErrors thrown from the backend (e.g., validation errors)
      print('FirebaseFunctionsException: ${e.code} - ${e.message}');
      throw Exception(e.message ?? 'Failed to submit report.');
    } catch (e) {
      print('An unexpected error occurred: $e');
      throw Exception('An unexpected error occurred during report submission.');
    }
  }
}