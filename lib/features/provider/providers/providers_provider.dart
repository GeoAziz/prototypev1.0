import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/enums/service_category.dart';
import '../../../core/models/provider.dart' as provider_model;

final nearbyProvidersStreamProvider =
    StreamProvider.family<
      List<provider_model.Provider>,
      NearbyProvidersParams
    >((ref, params) {
      final query = FirebaseFirestore.instance
          .collection('providers')
          .where('isActive', isEqualTo: true);

      Query filteredQuery = query;

      if (params.category != null) {
        filteredQuery = filteredQuery.where(
          'serviceCategories',
          arrayContains: params.category.toString(),
        );
      }

      if (params.searchQuery != null && params.searchQuery!.isNotEmpty) {
        filteredQuery = filteredQuery
            .where('businessName', isGreaterThanOrEqualTo: params.searchQuery)
            .where(
              'businessName',
              isLessThanOrEqualTo: params.searchQuery! + '\uf8ff',
            );
      }

      // For location filtering, you would use a geo query package, but here we just stream all for simplicity
      return filteredQuery.snapshots().map((snapshot) {
        return snapshot.docs
            .map((doc) {
              final data = doc.data();
              if (data == null) return null;
              final map = Map<String, dynamic>.from(
                data as Map<String, dynamic>,
              );
              map['id'] = doc.id;
              return provider_model.Provider.fromJson(map);
            })
            .whereType<provider_model.Provider>()
            .toList();
      });
    });

final providersProvider = Provider<_ProvidersProviderNotifier>(
  (ref) => _ProvidersProviderNotifier(),
);

class _ProvidersProviderNotifier {
  Future<provider_model.Provider?> getProviderById(String id) async {
    // TODO: Implement actual Firestore or repository lookup
    return null;
  }
}

class NearbyProvidersParams {
  final GeoPoint center;
  final double radius;
  final ServiceCategory? category;
  final String? searchQuery;

  NearbyProvidersParams({
    required this.center,
    required this.radius,
    this.category,
    this.searchQuery,
  });
}
