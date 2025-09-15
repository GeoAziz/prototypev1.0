import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseService {
  // Simple in-memory cache for provider queries
  final Map<String, List<DocumentSnapshot>> _providerCategoryCache = {};
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection names
  static const String providersCollection = 'providers';
  static const String reviewsCollection = 'reviews';
  static const String categoriesCollection = 'categories';

  // Getters for Firebase instances
  FirebaseFirestore get firestore => _firestore;
  FirebaseAuth get auth => _auth;

  // Helper method to get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Helper method to check if user is logged in
  bool get isUserLoggedIn => _auth.currentUser != null;

  // Google Sign In
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        '561314373498-pluhr0s4r9a5ntcgfsjpdpgto8br6076.apps.googleusercontent.com',
    scopes: ['email', 'profile'],
  );

  Future<UserCredential?> signInWithGoogle() async {
    try {
      await _googleSignIn.signOut(); // Clear any existing sign in

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) return null;

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google Auth credential
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      print('Error signing in with Google: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  // Helper method to get a collection reference with type safety
  CollectionReference<Map<String, dynamic>> collection(String path) {
    return _firestore.collection(path);
  }

  // Helper method to get a document reference with type safety
  DocumentReference<Map<String, dynamic>> document(String path) {
    return _firestore.doc(path);
  }

  // Get service providers by category
  Future<List<DocumentSnapshot>> getProvidersByCategory(
    String categoryId,
  ) async {
    // Check cache first
    if (_providerCategoryCache.containsKey(categoryId)) {
      return _providerCategoryCache[categoryId]!;
    }
    try {
      final querySnapshot = await _firestore
          .collection(providersCollection)
          .where('categoryId', isEqualTo: categoryId)
          .where('isActive', isEqualTo: true)
          .orderBy('rating', descending: true)
          .get();
      _providerCategoryCache[categoryId] = querySnapshot.docs;
      return querySnapshot.docs;
    } catch (e) {
      print('Error getting providers by category: $e');
      rethrow;
    }
    // For production: Use geohashing for efficient location queries
    // Recommended package: geoflutterfire2 (https://pub.dev/packages/geoflutterfire2)
    // Example usage:
    // import 'package:geoflutterfire2/geoflutterfire2.dart';
    // final geo = GeoFlutterFire();
    // geo.collection(collectionRef: ...).within(center: ..., radius: ..., field: ...);
  }

  // Get nearby service providers within a radius
  Future<List<DocumentSnapshot>> getNearbyProviders({
    required GeoPoint center,
    required double radiusInKm,
    String? categoryId,
  }) async {
    try {
      // Calculate the rough bounding box for initial filtering
      // This is a simplified approach - for production, consider using a proper geohashing solution
      final double lat = center.latitude;
      final double lon = center.longitude;
      final double latChange = radiusInKm / 111.32; // 1 degree = 111.32 km
      final double lonChange = radiusInKm / (111.32 * cos(lat * pi / 180));

      var query = _firestore
          .collection(providersCollection)
          .where('location.latitude', isGreaterThan: lat - latChange)
          .where('location.latitude', isLessThan: lat + latChange)
          .where('location.longitude', isGreaterThan: lon - lonChange)
          .where('location.longitude', isLessThan: lon + lonChange)
          .where('isActive', isEqualTo: true);

      if (categoryId != null) {
        query = query.where('categoryId', isEqualTo: categoryId);
      }

      final querySnapshot = await query.get();

      // Further filter results by exact distance
      return querySnapshot.docs.where((doc) {
        final providerLocation = doc.get('location') as GeoPoint;
        final distance = _calculateDistance(
          center.latitude,
          center.longitude,
          providerLocation.latitude,
          providerLocation.longitude,
        );
        return distance <= radiusInKm;
      }).toList();
    } catch (e) {
      print('Error getting nearby providers: $e');
      rethrow;
    }
  }

  // Get provider details
  Future<DocumentSnapshot?> getProviderDetails(String providerId) async {
    try {
      final docSnapshot = await _firestore
          .collection(providersCollection)
          .doc(providerId)
          .get();

      if (!docSnapshot.exists) {
        return null;
      }

      return docSnapshot;
    } catch (e) {
      print('Error getting provider details: $e');
      rethrow;
    }
  }

  // Get provider reviews
  Future<List<DocumentSnapshot>> getProviderReviews(
    String providerId, {
    DocumentSnapshot? lastDocument,
    int limit = 10,
  }) async {
    try {
      var query = _firestore
          .collection(reviewsCollection)
          .where('providerId', isEqualTo: providerId)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final querySnapshot = await query.get();
      return querySnapshot.docs;
    } catch (e) {
      print('Error getting provider reviews: $e');
      rethrow;
    }
  }

  // Helper method to calculate distance between two points using Haversine formula
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    double toRadians(double degree) {
      return degree * pi / 180;
    }

    final double dLat = toRadians(lat2 - lat1);
    final double dLon = toRadians(lon2 - lon1);

    final double a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(toRadians(lat1)) *
            cos(toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }
}
