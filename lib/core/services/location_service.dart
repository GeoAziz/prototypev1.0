import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../models/location.dart';
import '../models/provider.dart';
import '../enums/service_category.dart';

class LocationService {
  final _firestore = FirebaseFirestore.instance;
  final _locationStreamController = StreamController<Position>.broadcast();
  Stream<Position>? _locationStream;
  final Map<String, StreamSubscription<Position>> _locationSubscriptions = {};

  // Cache for provider data
  final Map<String, Provider> _providerCache = {};
  Timer? _cacheCleanupTimer;

  LocationService() {
    // Start cache cleanup timer
    _cacheCleanupTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      _cleanCache();
    });
  }

  Future<Position> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied.');
      }

      // Try to get last known position first for faster response
      Position? lastKnownPosition = await Geolocator.getLastKnownPosition();
      if (lastKnownPosition != null) {
        return lastKnownPosition;
      }

      return await Geolocator.getCurrentPosition();
    } catch (e) {
      print('Error getting current location: $e');
      rethrow;
    }
  }

  Future<bool> startBackgroundLocationUpdates(String providerId) async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationAccuracy.high ||
          permission == LocationPermission.whileInUse) {
        // Cancel existing subscription if any
        await stopBackgroundLocationUpdates(providerId);

        _locationStream = Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 100, // Update every 100 meters
          ),
        );

        _locationSubscriptions[providerId] = _locationStream!.listen(
          (Position position) async {
            try {
              await updateProviderLocation(
                providerId,
                Location(
                  latitude: position.latitude,
                  longitude: position.longitude,
                ),
              );
              _locationStreamController.add(position);

              // Cache last location in shared preferences
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString(
                'last_location_$providerId',
                '${position.latitude},${position.longitude}',
              );
            } catch (e) {
              print('Error updating provider location: $e');
              // Retry after delay
              await Future.delayed(const Duration(seconds: 30));
              if (_locationSubscriptions.containsKey(providerId)) {
                updateProviderLocation(
                  providerId,
                  Location(
                    latitude: position.latitude,
                    longitude: position.longitude,
                  ),
                );
              }
            }
          },
          onError: (error) {
            print('Location stream error: $error');
          },
        );

        return true;
      }
      return false;
    } catch (e) {
      print('Error starting background location updates: $e');
      return false;
    }
  }

  Future<void> stopBackgroundLocationUpdates(String providerId) async {
    await _locationSubscriptions[providerId]?.cancel();
    _locationSubscriptions.remove(providerId);
    if (_locationSubscriptions.isEmpty) {
      _locationStream = null;
    }
  }

  Stream<List<Provider>> getNearbyProviders(
    double lat,
    double lng,
    double radius, // radius in km
    ServiceCategory? serviceCategory,
  ) async* {
    final radiusInDegrees = radius / 111.0; // Approx. degrees per km at equator

    try {
      // Set up real-time listener for provider updates
      final Stream<QuerySnapshot> providerStream = _firestore
          .collection('providers')
          .where(
            'location',
            isGreaterThan: GeoPoint(
              lat - radiusInDegrees,
              lng - radiusInDegrees,
            ),
          )
          .where(
            'location',
            isLessThan: GeoPoint(lat + radiusInDegrees, lng + radiusInDegrees),
          )
          .where('isActive', isEqualTo: true)
          .snapshots();

      await for (final snapshot in providerStream) {
        try {
          final currentLocation = Location(latitude: lat, longitude: lng);
          final nearbyProviders = snapshot.docs
              .map((doc) {
                // Check cache first
                final cachedProvider = _providerCache[doc.id];
                if (cachedProvider != null &&
                    doc.data().toString() ==
                        cachedProvider.toJson().toString()) {
                  return cachedProvider;
                }

                // Create new provider and cache it
                final provider = Provider.fromJson({
                  ...doc.data() as Map<String, dynamic>,
                  'id': doc.id,
                });
                _providerCache[doc.id] = provider;
                return provider;
              })
              .where((provider) {
                if (provider.location == null) return false;

                final distance = calculateDistance(
                  currentLocation,
                  Location(
                    latitude: provider.location!.latitude,
                    longitude: provider.location!.longitude,
                  ),
                );

                final matchesCategory = serviceCategory == null
                    ? true
                    : provider.serviceCategories.contains(serviceCategory);

                return distance <= radius * 1000 && matchesCategory;
              })
              .toList();

          yield nearbyProviders;
        } catch (e) {
          print('Error processing provider snapshot: $e');
          continue;
        }
      }
    } catch (e) {
      print('Error getting nearby providers: $e');
      yield [];
    }
  }

  double calculateDistance(Location point1, Location point2) {
    return Geolocator.distanceBetween(
      point1.latitude,
      point1.longitude,
      point2.latitude,
      point2.longitude,
    );
  }

  Future<void> updateProviderLocation(
    String providerId,
    Location location,
  ) async {
    try {
      await _firestore.collection('providers').doc(providerId).update({
        'location': GeoPoint(location.latitude, location.longitude),
        'updatedAt': FieldValue.serverTimestamp(),
        'lastSeen': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating provider location: $e');
      rethrow;
    }
  }

  void _cleanCache() {
    const maxCacheAge = Duration(minutes: 30);
    final now = DateTime.now();
    _providerCache.removeWhere((_, provider) {
      return now.difference(provider.updatedAt) > maxCacheAge;
    });
  }

  void dispose() {
    for (var subscription in _locationSubscriptions.values) {
      subscription.cancel();
    }
    _locationSubscriptions.clear();
    _locationStreamController.close();
    _cacheCleanupTimer?.cancel();
    _providerCache.clear();
  }
}
