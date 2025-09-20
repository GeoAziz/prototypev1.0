import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:poafix/core/models/category.dart';
import 'package:poafix/core/services/base_service.dart';

class CategoryService extends BaseService {
  CategoryService({super.firestore});

  // Cache for categories
  List<Category>? _cachedCategories;
  DateTime? _lastFetch;
  static const _cacheTimeout = Duration(minutes: 5);

  Future<List<Category>> getCategories({
    bool? isFeatured,
    bool? isPopular,
    bool useCache = true,
  }) async {
    return handleServiceCall(() async {
      // Check cache if enabled
      if (useCache && _cachedCategories != null && _lastFetch != null) {
        final now = DateTime.now();
        if (now.difference(_lastFetch!) < _cacheTimeout) {
          var filtered = _cachedCategories!;
          if (isFeatured != null) {
            filtered = filtered
                .where((c) => c.isFeatured == isFeatured)
                .toList();
          }
          if (isPopular != null) {
            filtered = filtered.where((c) => c.isPopular == isPopular).toList();
          }
          return filtered;
        }
      }

      Query<Map<String, dynamic>> query = firestore.collection(
        'serviceCategories',
      );

      if (isFeatured != null) {
        query = query.where('isFeatured', isEqualTo: isFeatured);
      }
      if (isPopular != null) {
        query = query.where('isPopular', isEqualTo: isPopular);
      }

      final snapshot = await query.get();
      final categories = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Category.fromJson(data);
      }).toList();

      // Update cache if we fetched all categories
      if (isFeatured == null && isPopular == null) {
        _cachedCategories = categories;
        _lastFetch = DateTime.now();
      }

      return categories;
    });
  }

  Future<Category?> getCategoryById(String id) async {
    return handleServiceCall(() async {
      // Check cache first
      if (_cachedCategories != null) {
        try {
          return _cachedCategories!.firstWhere((c) => c.id == id);
        } catch (_) {
          // Category not found in cache
        }
      }

      final doc = await firestore.collection('serviceCategories').doc(id).get();
      if (!doc.exists) return null;

      final data = doc.data()!;
      data['id'] = doc.id;
      return Category.fromJson(data);
    });
  }

  Stream<List<Category>> streamCategories({bool? isFeatured, bool? isPopular}) {
    return handleServiceStream(
      firestore.collection('serviceCategories').snapshots().map((snapshot) {
        var categories = snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return Category.fromJson(data);
        }).toList();

        if (isFeatured != null) {
          categories = categories
              .where((c) => c.isFeatured == isFeatured)
              .toList();
        }
        if (isPopular != null) {
          categories = categories
              .where((c) => c.isPopular == isPopular)
              .toList();
        }

        return categories;
      }),
    );
  }
}
