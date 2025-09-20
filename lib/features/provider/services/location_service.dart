import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  // Request location permission
  Future<bool> requestLocationPermission() async {
    final permission = await Geolocator.requestPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  // Check if location services are enabled
  Future<bool> isLocationServiceEnabled() {
    return Geolocator.isLocationServiceEnabled();
  }

  // Get current position
  Future<Position?> getCurrentPosition() async {
    try {
      if (!await isLocationServiceEnabled()) {
        return null;
      }

      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final newPermission = await requestLocationPermission();
        if (!newPermission) {
          return null;
        }
      }

      return await Geolocator.getCurrentPosition();
    } catch (e) {
      print('Error getting current position: $e');
      return null;
    }
  }

  // Get last known position
  Future<Position?> getLastKnownPosition() {
    return Geolocator.getLastKnownPosition();
  }

  // Calculate distance between two points
  double calculateDistance(GeoPoint point1, GeoPoint point2) {
    return Geolocator.distanceBetween(
      point1.latitude,
      point1.longitude,
      point2.latitude,
      point2.longitude,
    );
  }

  // Format distance for display
  String formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.toStringAsFixed(0)}m';
    } else {
      return '${(distanceInMeters / 1000).toStringAsFixed(1)}km';
    }
  }

  // Get location stream
  Stream<Position> getPositionStream({
    int distanceFilter = 10,
    Duration? interval,
  }) {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        distanceFilter: distanceFilter,
        accuracy: LocationAccuracy.high,
      ),
    );
  }

  // Convert Position to GeoPoint
  GeoPoint positionToGeoPoint(Position position) {
    return GeoPoint(position.latitude, position.longitude);
  }

  // Get formatted address from coordinates (you can implement this using a geocoding package)
  Future<String?> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    // Implement using geocoding package
    return null;
  }
}
