import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:poafix/core/models/service.dart';
import 'package:poafix/core/services/base_service.dart';

class ServiceService extends BaseService {
  ServiceService({super.firestore});

  // Validate required fields for a service
  bool _validateServiceData(Map<String, dynamic> data, String docId) {
    final requiredFields = {
      'name': 'String',
      'description': 'String',
      'price': 'num',
      'categoryId': 'String',
      'image': 'String',
      'rating': 'num',
      'reviewCount': 'int',
      'bookingCount': 'int',
      'images': 'List<String>',
      'features': 'List<String>',
      'providerId': 'String',
    };

    for (var field in requiredFields.entries) {
      if (!data.containsKey(field.key)) {
        print(
          'Skipping service doc $docId due to missing required field: ${field.key}',
        );
        return false;
      }

      // Type validation for specific fields
      switch (field.value) {
        case 'String':
          if (data[field.key] == null || data[field.key] is! String) {
            print('Skipping service doc $docId: ${field.key} must be a String');
            return false;
          }
          break;
        case 'num':
          if (data[field.key] == null || data[field.key] is! num) {
            print('Skipping service doc $docId: ${field.key} must be a number');
            return false;
          }
          break;
        case 'int':
          if (data[field.key] == null || data[field.key] is! int) {
            print(
              'Skipping service doc $docId: ${field.key} must be an integer',
            );
            return false;
          }
          break;
        case 'List<String>':
          if (data[field.key] == null || data[field.key] is! List) {
            print('Skipping service doc $docId: ${field.key} must be a List');
            return false;
          }
          if (!(data[field.key] as List).every((item) => item is String)) {
            print(
              'Skipping service doc $docId: ${field.key} must contain only strings',
            );
            return false;
          }
          break;
      }
    }

    return true;
  }

  // Get services with filtering, search, sorting, and pagination
  Future<List<Service>> getServices({
    String? categoryId,
    bool? isFeatured,
    bool? isPopular,
    String? searchQuery,
    String? sortBy,
    bool descending = true,
    int? limit,
    DocumentSnapshot? startAfter,
  }) {
    return handleServiceCall(() async {
      Query<Map<String, dynamic>> query = firestore.collection('services');

      if (categoryId != null) {
        query = query.where('categoryId', isEqualTo: categoryId);
      }
      if (isFeatured != null) {
        query = query.where('isFeatured', isEqualTo: isFeatured);
      }
      if (isPopular != null) {
        query = query.where('isPopular', isEqualTo: isPopular);
      }

      // Apply search if provided
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final searchTerms = searchQuery
            .toLowerCase()
            .split(' ')
            .where((term) => term.isNotEmpty)
            .toList();

        if (searchTerms.isNotEmpty) {
          // Using array-contains with keywords field for basic search
          // For production, consider using a proper search solution like Algolia
          query = query.where('searchKeywords', arrayContains: searchTerms[0]);
        }
      }

      // Apply sorting
      if (sortBy != null) {
        switch (sortBy) {
          case 'price_low':
            query = query.orderBy('price', descending: false);
            break;
          case 'price_high':
            query = query.orderBy('price', descending: true);
            break;
          case 'rating':
            query = query.orderBy('rating', descending: true);
            break;
          case 'popularity':
            query = query.orderBy('bookingCount', descending: true);
            break;
          default:
            query = query.orderBy('createdAt', descending: true);
        }
      } else {
        // Default sorting
        query = query.orderBy('createdAt', descending: true);
      }

      // Apply pagination
      if (limit != null) {
        query = query.limit(limit);
      }
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .where((doc) {
            final data = doc.data();
            return _validateServiceData(data, doc.id);
          })
          .map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return Service.fromJson(data);
          })
          .toList();
    });
  }

  // Get a single service by ID
  Future<Service?> getServiceById(String id) {
    return handleServiceCall(() async {
      final doc = await firestore.collection('services').doc(id).get();
      if (!doc.exists) return null;

      final data = doc.data()!;
      if (!_validateServiceData(data, doc.id)) {
        return null;
      }

      data['id'] = doc.id;
      return Service.fromJson(data);
    });
  }

  // Stream services with real-time updates
  Stream<List<Service>> streamServices({
    String? categoryId,
    bool? isFeatured,
    bool? isPopular,
    String? sortBy,
    bool descending = true,
    int? limit,
  }) {
    return handleServiceStream(
      firestore.collection('services').snapshots().map((snapshot) {
        var services = snapshot.docs
            .where((doc) {
              final data = doc.data();
              return _validateServiceData(data, doc.id);
            })
            .map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return Service.fromJson(data);
            })
            .toList();

        if (categoryId != null) {
          services = services.where((s) => s.categoryId == categoryId).toList();
        }
        if (isFeatured != null) {
          services = services.where((s) => s.isFeatured == isFeatured).toList();
        }
        if (isPopular != null) {
          services = services.where((s) => s.isPopular == isPopular).toList();
        }

        // Apply sorting
        if (sortBy != null) {
          switch (sortBy) {
            case 'price':
              services.sort(
                (a, b) => descending
                    ? b.price.compareTo(a.price)
                    : a.price.compareTo(b.price),
              );
              break;
            case 'rating':
              services.sort((a, b) => b.rating.compareTo(a.rating));
              break;
            case 'popularity':
              services.sort((a, b) => b.bookingCount.compareTo(a.bookingCount));
              break;
            default:
            // No default sorting
          }
        }

        if (limit != null && services.length > limit) {
          services = services.take(limit).toList();
        }

        return services;
      }),
    );
  }

  // Get services near a location
  Future<List<Service>> getNearbyServices({
    required GeoPoint location,
    required double radiusInKm,
    String? categoryId,
    int? limit,
  }) {
    return handleServiceCall(() async {
      // Calculate rough bounding box for initial filtering
      final lat = location.latitude;
      final lon = location.longitude;
      final latChange = radiusInKm / 111.32; // 1 degree = 111.32 km
      final lonChange = radiusInKm / (111.32 * cos(lat * pi / 180));

      var query = firestore
          .collection('services')
          .where('location.latitude', isGreaterThan: lat - latChange)
          .where('location.latitude', isLessThan: lat + latChange)
          .where('location.longitude', isGreaterThan: lon - lonChange)
          .where('location.longitude', isLessThan: lon + lonChange);

      if (categoryId != null) {
        query = query.where('categoryId', isEqualTo: categoryId);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      final services = snapshot.docs
          .where((doc) {
            final data = doc.data();
            return _validateServiceData(data, doc.id);
          })
          .map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return Service.fromJson(data);
          })
          .toList();

      // Further filter by exact distance
      return services.where((service) {
        if (service.location == null) return false;
        final distance = _calculateDistance(
          location.latitude,
          location.longitude,
          service.location!.latitude,
          service.location!.longitude,
        );
        return distance <= radiusInKm;
      }).toList();
    });
  }

  // Helper method to calculate distance between two points
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
