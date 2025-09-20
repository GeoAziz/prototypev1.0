import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:poafix/core/models/service.dart';
import 'package:poafix/core/models/service_query_result.dart';
import 'package:poafix/core/services/base_service.dart';
import 'package:poafix/core/utils/logger.dart';

class ServiceService extends BaseService {
  ServiceService({super.firestore}) {
    _logger = Logger('ServiceService');
  }

  late final Logger _logger;

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
      'features': 'List<String>',
      // Optional fields
      // 'images': 'List<String>',
      // 'providerId': 'String',
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
          final value = data[field.key];
          if (value == null) {
            // If list is null, we'll let the model handle it with defaults
            return true;
          }
          if (value is! List) {
            print('Skipping service doc $docId: ${field.key} must be a List');
            return false;
          }
          // Allow empty lists - the model will handle defaults
          if (value.isEmpty) {
            return true;
          }
          if (!value.every(
            (item) => item != null && item.toString().isNotEmpty,
          )) {
            print(
              'Skipping service doc $docId: ${field.key} contains null or empty values',
            );
            return false;
          }
          break;
      }
    }

    return true;
  }

  // Get services with filtering, search, sorting, and pagination
  Future<ServiceQueryResult> getServices({
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

      return ServiceQueryResult(
        services: services,
        lastDocument: services.isEmpty ? null : snapshot.docs.last,
        hasMore: services.length >= (limit ?? 10),
      );
    });
  }

  // Get a single service by ID with provider data
  Future<Service?> getServiceById(String id) {
    return handleServiceCall(() async {
      final doc = await firestore.collection('services').doc(id).get();
      if (!doc.exists) return null;

      final data = doc.data()!;
      if (!_validateServiceData(data, doc.id)) {
        return null;
      }

      // Get provider data
      final providerId = data['providerId'] as String?;
      if (providerId != null && providerId.isNotEmpty) {
        final providerDoc = await firestore
            .collection('providers')
            .doc(data['providerId'] as String)
            .get();

        if (providerDoc.exists) {
          final providerData = providerDoc.data()!;
          data['location'] = providerData['location'];
          data['providerName'] = providerData['businessName'];
          data['providerRating'] = providerData['rating'];
          data['providerReviewCount'] = providerData['reviewCount'];
        }
      }

      data['id'] = doc.id;
      return Service.fromJson(data);
    });
  }

  // Stream services with real-time updates
  Stream<List<Service>> streamServices({
    String? providerId,
    String? categoryId,
    bool? isFeatured,
    bool? isPopular,
    String? sortBy,
    bool descending = true,
    int? limit,
  }) {
    _logger.debug(
      'Streaming services with filters: categoryId=$categoryId, providerId=$providerId, '
      'isFeatured=$isFeatured, isPopular=$isPopular, sortBy=$sortBy',
    );
    Query<Map<String, dynamic>> query = firestore.collection('services');

    // Apply filters
    if (providerId != null && providerId.isNotEmpty) {
      query = query.where('providerId', isEqualTo: providerId);
    }
    if (categoryId != null) {
      query = query.where('categoryId', isEqualTo: categoryId);
    }
    if (isFeatured != null) {
      query = query.where('isFeatured', isEqualTo: isFeatured);
    }
    if (isPopular != null) {
      query = query.where('isPopular', isEqualTo: isPopular);
    }

    // Apply sorting if needed
    switch (sortBy) {
      case 'price':
        query = query.orderBy('price', descending: descending);
        break;
      case 'rating':
        query = query.orderBy('rating', descending: true);
        break;
      case 'popularity':
        query = query.orderBy('bookingCount', descending: true);
        break;
    }

    // Apply limit if specified
    if (limit != null) {
      query = query.limit(limit);
    }

    return handleServiceStream(
      query.snapshots().asyncMap((snapshot) async {
        final validDocs = snapshot.docs.where((doc) {
          final data = doc.data();
          return _validateServiceData(data, doc.id);
        }).toList();

        // Get provider data for all services in parallel
        final providerIds = validDocs
            .map((doc) => doc.data()['providerId'] as String?)
            .where((id) => id != null)
            .toSet();

        final providerDocs = await Future.wait(
          providerIds.map(
            (id) => firestore.collection('providers').doc(id!).get(),
          ),
        );

        final providerDataMap = Map.fromEntries(
          providerDocs
              .where((doc) => doc.exists)
              .map((doc) => MapEntry(doc.id, doc.data()!)),
        );

        // Combine service data with provider data
        final services = validDocs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;

          final providerId = data['providerId'] as String?;
          if (providerId != null && providerDataMap.containsKey(providerId)) {
            final providerData = providerDataMap[providerId]!;
            data['location'] = providerData['location'];
            data['providerName'] = providerData['businessName'];
            data['providerRating'] = providerData['rating'];
            data['providerReviewCount'] = providerData['reviewCount'];
          }

          return Service.fromJson(data);
        }).toList();

        _logger.info(
          'Streamed ${services.length} services with categoryId=$categoryId',
        );

        return services;
      }),
    );
  }

  // Add a new service
  Future<String> addService(Service service) {
    return handleServiceCall(() async {
      final docRef = await firestore
          .collection('services')
          .add(service.toJson());
      return docRef.id;
    });
  }

  // Update an existing service
  Future<void> updateService(String id, Map<String, dynamic> updates) {
    return handleServiceCall(() async {
      await firestore.collection('services').doc(id).update(updates);
    });
  }

  // Delete a service
  Future<void> deleteService(String id) {
    return handleServiceCall(() async {
      await firestore.collection('services').doc(id).delete();
    });
  }

  // Get services near a location using provider locations
  Future<List<Service>> getNearbyServices({
    required GeoPoint location,
    required double radiusInKm,
    String? categoryId,
    int? limit,
  }) {
    return handleServiceCall(() async {
      // Find providers within radius first
      final lat = location.latitude;
      final lon = location.longitude;
      final latChange = radiusInKm / 111.32; // 1 degree = 111.32 km
      final lonChange = radiusInKm / (111.32 * cos(lat * pi / 180));

      var providerQuery = firestore
          .collection('providers')
          .where('location.latitude', isGreaterThan: lat - latChange)
          .where('location.latitude', isLessThan: lat + latChange);

      final providerDocs = await providerQuery.get();
      final nearbyProviderIds = providerDocs.docs
          .where((doc) {
            final location = doc.data()['location'] as GeoPoint?;
            if (location == null) return false;

            final distance = _calculateDistance(
              lat,
              lon,
              location.latitude,
              location.longitude,
            );
            return distance <= radiusInKm;
          })
          .map((doc) => doc.id)
          .toList();

      if (nearbyProviderIds.isEmpty) return [];

      // Get services from nearby providers
      var query = firestore
          .collection('services')
          .where('providerId', whereIn: nearbyProviderIds);

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
            final providerId = data['providerId'] as String?;
            if (providerId != null) {
              final providerDoc = providerDocs.docs.firstWhere(
                (d) => d.id == providerId,
              );
              if (providerDoc.exists) {
                final providerData = providerDoc.data();
                data['location'] = providerData['location'];
                data['providerName'] = providerData['businessName'];
                data['providerRating'] = providerData['rating'];
                data['providerReviewCount'] = providerData['reviewCount'];
              }
            }
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
