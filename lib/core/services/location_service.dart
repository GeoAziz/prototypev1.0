import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire3/geoflutterfire3.dart';
import '../models/provider.dart';

class LocationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final geo = GeoFlutterFire();

  Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied.');
    }

    return await Geolocator.getCurrentPosition();
  }

  Stream<List<ServiceProvider>> getNearbyProviders(
    double lat,
    double lng,
    double radius, // radius in km
  ) {
    GeoFirePoint center = geo.point(latitude: lat, longitude: lng);

    // Use 'geopoint' field for GeoFlutterFire compatibility
    return geo
        .collection(collectionRef: _firestore.collection('providers'))
        .within(
          center: center,
          radius: radius,
          field: 'geopoint',
          strictMode: true,
        )
        .map((docs) {
          return docs.map((doc) => ServiceProvider.fromFirestore(doc)).toList();
        });
  }

  double calculateDistance(GeoPoint point1, GeoPoint point2) {
    return Geolocator.distanceBetween(
      point1.latitude,
      point1.longitude,
      point2.latitude,
      point2.longitude,
    );
  }

  Future<void> updateProviderLocation(
    String providerId,
    GeoPoint location,
  ) async {
    GeoFirePoint geoPoint = geo.point(
      latitude: location.latitude,
      longitude: location.longitude,
    );

    await _firestore.collection('providers').doc(providerId).update({
      'location': location,
      'geopoint': geoPoint.data,
    });
  }
}
