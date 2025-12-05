import 'package:geolocator/geolocator.dart';

/// A service class dedicated to handling all location-related operations.
class LocationService {
  /// Determines the current position of the device.
  ///
  /// When the location services are not enabled or permissions are not granted,
  /// this method handles the request and throws an error that should be caught.
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. Check if location services are enabled on the device.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are disabled. Don't continue accessing the position.
      throw Exception('Location services are disabled. Please enable them.');
    }

    // 2. Check for location permissions.
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are still denied, handle the error.
        throw Exception('Location permissions are denied. Cannot proceed.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle this case.
      throw Exception(
        'Location permissions are permanently denied. Please enable them in app settings.',
      );
    }

    // 3. Permissions granted, return the current position.
    // We use a high accuracy setting for reporting.
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  /// Helper method to format the Position object into a readable map for the database.
  static Map<String, double> positionToMap(Position position) {
    return {
      'latitude': position.latitude,
      'longitude': position.longitude,
      'accuracy': position.accuracy,
    };
  }
}