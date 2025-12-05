import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class IssueReport {
  final String id;
  final String reporterUid;
  final String description;
  final String category;
  final String priority;
  final String imageUrl;
  final String locationString;
  final double lat;
  final double lng;
  final DateTime timestamp;
  final String status;

  IssueReport({
    required this.id,
    required this.reporterUid,
    required this.description,
    required this.category,
    required this.priority,
    required this.imageUrl,
    required this.locationString,
    required this.lat,
    required this.lng,
    required this.timestamp,
    this.status = 'Reported',
  });

  Map<String, dynamic> toMap() {
    return {
      'reporterUid': reporterUid,
      'description': description,
      'category': category,
      'priority': priority,
      'imageUrl': imageUrl,
      'locationString': locationString,
      'lat': lat,
      'lng': lng,
      'timestamp': Timestamp.fromDate(timestamp), // Use Firestore Timestamp
      'status': status,
    };
  }
  // Factory constructor to create IssueReport from Firestore Map
  factory IssueReport.fromMap(String id, Map<String, dynamic> map) {
    return IssueReport(
      id: id,
      reporterUid: map['reporterUid'] ?? 'unknown',
      description: map['description'] ?? '',
      category: map['category'] ?? 'Other',
      priority: map['priority'] ?? 'Low',
      imageUrl: map['imageUrl'] ?? '',
      locationString: map['locationString'] ?? 'Unknown Location',
      lat: (map['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (map['lng'] as num?)?.toDouble() ?? 0.0,
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: map['status'] ?? 'Reported',
    );
  }
  
}

class ReportService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> submitReport({
    required String description,
    required String category,
    required String priority,
    required String imageUrl,
    required String locationString,
    required double lat,
    required double lng,
    required String reporterUid, // Ensure this is passed
  }) async {
    // Reference to the 'issueReports' collection
    //final collectionRef = _db.collection('reports').doc();
    const String existingDocId = 'dnOKQ2DXDib4kco9BOgc';
    // Create a new document reference to get the ID
    //final docRef = collectionRef.doc('dnOKQ2DXDib4kco9BOgc');
    final docRef = _db.collection('reports').doc(existingDocId);


    final report = IssueReport(
      //id: docRef.id,
      id: existingDocId,
      reporterUid: reporterUid,
      description: description,
      category: category,
      priority: priority,
      imageUrl: imageUrl,
      locationString: locationString,
      lat: lat,
      lng: lng,
      timestamp: DateTime.now(),
      status: 'Reported',
    );

    await docRef.set(
      report.toMap()..['timestamp'] = FieldValue.serverTimestamp(),
      SetOptions(merge: true),
    );
    print('Report $existingDocId successfully updated in Firestore!');
  }
}

class FirebaseService {
  // Get a reference to the root of the Realtime Database
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();

  // --- 1. WRITE FUNCTION (Reporting an Issue) ---
  Future<void> reportIssue(IssueReport report) async {
    // 1. Define the path where the data will be stored (e.g., 'issues/unique_id')
    final issuesRef = _databaseRef.child('issues').push();
    
    try {
      // 2. Set the data using the toJson map
      await issuesRef.set(report.toMap());
      if (kDebugMode) {
        print('Issue successfully reported with key: ${issuesRef.key}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error reporting issue: $e');
      }
      rethrow; // Re-throw the error for the UI to handle
    }
  }

  // --- 2. READ FUNCTION (Real-time stream for Dashboard) ---
  // This function returns a stream of DataSnapshot, allowing you to react 
  // immediately when data changes in the 'issues' path.
  Stream<DatabaseEvent> getIssuesStream() {
    return _databaseRef.child('issues').onValue;
  }
}