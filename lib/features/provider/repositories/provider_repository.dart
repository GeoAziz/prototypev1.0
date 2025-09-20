import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import '../../../core/models/provider.dart';
import '../../../core/enums/service_category.dart';

class ProviderRepository {
  final FirebaseFirestore _firestore;
  final GeoFlutterFire _geo;
  final String _collection = 'providers';

  ProviderRepository({FirebaseFirestore? firestore, GeoFlutterFire? geo})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _geo = geo ?? GeoFlutterFire();

  // Get a stream of nearby providers within a certain radius
  Stream<List<Provider>> getNearbyProviders({
    required GeoPoint center,
    required double radius,
    ServiceCategory? category,
    String? searchQuery,
    bool activeOnly = true,
  }) {
    // Create a geoFirePoint
    final geoRef = _geo.point(
      latitude: center.latitude,
      longitude: center.longitude,
    );

    // Build the base query
    Query query = _firestore.collection(_collection);

    // Add filters
    if (activeOnly) {
      query = query.where('isActive', isEqualTo: true);
    }

    if (category != null) {
      query = query.where(
        'serviceCategories',
        arrayContains: category.toString(),
      );
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = query
          .where('businessName', isGreaterThanOrEqualTo: searchQuery)
          .where('businessName', isLessThanOrEqualTo: searchQuery + '\uf8ff');
    }

    return _geo
        .collection(collectionRef: query)
        .within(center: geoRef, radius: radius, field: 'location')
        .map((List<DocumentSnapshot> documents) {
          return documents.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id; // Ensure the document ID is included
            return Provider.fromJson(data);
          }).toList();
        });
  }

  // Get a single provider by ID
  Future<Provider?> getProviderById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (!doc.exists) return null;

      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return Provider.fromJson(data);
    } catch (e) {
      print('Error fetching provider: $e');
      return null;
    }
  }

  // Update provider location
  Future<void> updateProviderLocation(
    String providerId,
    GeoPoint location,
  ) async {
    try {
      await _firestore.collection(_collection).doc(providerId).update({
        'location': location,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error updating provider location: $e');
      throw e;
    }
  }

  // Update provider status (active/inactive)
  Future<void> updateProviderStatus(String providerId, bool isActive) async {
    try {
      await _firestore.collection(_collection).doc(providerId).update({
        'isActive': isActive,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error updating provider status: $e');
      throw e;
    }
  }

  // Get top rated providers
  Future<List<Provider>> getTopRatedProviders({
    int limit = 10,
    ServiceCategory? category,
  }) async {
    try {
      Query query = _firestore
          .collection(_collection)
          .where('isActive', isEqualTo: true)
          .orderBy('rating', descending: true)
          .limit(limit);

      if (category != null) {
        query = query.where(
          'serviceCategories',
          arrayContains: category.toString(),
        );
      }

      final querySnapshot = await query.get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Provider.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error fetching top rated providers: $e');
      return [];
    }
  }

  // Update provider rating
  Future<void> updateProviderRating(String providerId, double newRating) async {
    try {
      // Get the current provider data
      final doc = await _firestore
          .collection(_collection)
          .doc(providerId)
          .get();
      if (!doc.exists) throw Exception('Provider not found');

      final data = doc.data() as Map<String, dynamic>;
      final currentTotalRatings = data['totalRatings'] as int? ?? 0;
      final currentRating = (data['rating'] as num?)?.toDouble() ?? 0.0;

      // Calculate the new average rating
      final totalRatingPoints = currentRating * currentTotalRatings;
      final newTotalRatings = currentTotalRatings + 1;
      final newAverageRating =
          (totalRatingPoints + newRating) / newTotalRatings;

      // Update the provider document
      await _firestore.collection(_collection).doc(providerId).update({
        'rating': newAverageRating,
        'totalRatings': newTotalRatings,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error updating provider rating: $e');
      throw e;
    }
  }
}
