import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:poafix/core/models/service.dart';
import 'package:poafix/features/smart_filtering/models/filter_criteria.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SmartFilteringService extends ChangeNotifier {
  static final SmartFilteringService _instance =
      SmartFilteringService._internal();
  factory SmartFilteringService() => _instance;
  SmartFilteringService._internal();

  FilterCriteria _currentCriteria = const FilterCriteria();
  bool _isLoading = false;
  String? _error;

  FilterCriteria get currentCriteria => _currentCriteria;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Save filter preferences
  Future<void> saveFilterPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final criteriaJson = jsonEncode(_currentCriteria.toJson());
      await prefs.setString('filter_criteria', criteriaJson);
    } catch (e) {
      print('Error saving filter preferences: $e');
    }
  }

  // Load filter preferences
  Future<void> loadFilterPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final criteriaJson = prefs.getString('filter_criteria');
      if (criteriaJson != null) {
        final criteriaMap = jsonDecode(criteriaJson);
        _currentCriteria = FilterCriteria.fromJson(criteriaMap);
        notifyListeners();
      }
    } catch (e) {
      print('Error loading filter preferences: $e');
    }
  }

  // Update filter criteria
  void updateCriteria(FilterCriteria criteria) {
    _currentCriteria = criteria;
    notifyListeners();
    saveFilterPreferences();
  }

  // Clear all filters
  void clearFilters() {
    _currentCriteria = const FilterCriteria();
    notifyListeners();
    saveFilterPreferences();
  }

  // Apply filters to Firestore query
  Query<Map<String, dynamic>> applyFiltersToQuery(
    CollectionReference<Map<String, dynamic>> collection,
  ) {
    Query<Map<String, dynamic>> query = collection;

    // Price filters
    if (_currentCriteria.minPrice != null) {
      query = query.where(
        'price',
        isGreaterThanOrEqualTo: _currentCriteria.minPrice,
      );
    }
    if (_currentCriteria.maxPrice != null) {
      query = query.where(
        'price',
        isLessThanOrEqualTo: _currentCriteria.maxPrice,
      );
    }

    // Rating filter
    if (_currentCriteria.minRating != null) {
      query = query.where(
        'rating',
        isGreaterThanOrEqualTo: _currentCriteria.minRating,
      );
    }

    // Category filter
    if (_currentCriteria.selectedCategories.isNotEmpty) {
      query = query.where(
        'categoryId',
        whereIn: _currentCriteria.selectedCategories,
      );
    }

    // Active services only
    query = query.where('active', isEqualTo: true);

    // Availability filter
    if (_currentCriteria.onlyAvailable) {
      query = query.where('available', isEqualTo: true);
    }

    // Apply sorting
    switch (_currentCriteria.sortBy) {
      case 'price':
        query = query.orderBy('price', descending: !_currentCriteria.ascending);
        break;
      case 'rating':
        query = query.orderBy(
          'rating',
          descending: !_currentCriteria.ascending,
        );
        break;
      case 'popularity':
        query = query.orderBy(
          'bookingCount',
          descending: !_currentCriteria.ascending,
        );
        break;
      default:
        query = query.orderBy('createdAt', descending: true);
    }

    return query;
  }

  // Filter services list (for additional client-side filtering)
  List<Service> filterServices(List<Service> services) {
    List<Service> filtered = services;

    // Feature filters (client-side as features are arrays)
    if (_currentCriteria.selectedFeatures.isNotEmpty) {
      filtered = filtered.where((service) {
        return _currentCriteria.selectedFeatures.every(
          (feature) => service.features.contains(feature),
        );
      }).toList();
    }

    // Location distance filter (would need geolocation service)
    if (_currentCriteria.location != null &&
        _currentCriteria.maxDistance != null) {
      // TODO: Implement distance calculation based on service location
      // This would require geocoding and distance calculation
    }

    // Availability time filter
    if (_currentCriteria.availableFrom != null ||
        _currentCriteria.availableTo != null) {
      // TODO: Filter based on provider availability schedules
      // This would require integration with booking/availability system
    }

    return filtered;
  }

  // Get available categories for filtering
  Future<List<String>> getAvailableCategories() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('serviceCategories')
          .where('active', isEqualTo: true)
          .get();

      return snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      print('Error fetching categories: $e');
      return [];
    }
  }

  // Get available features for filtering
  Future<List<String>> getAvailableFeatures() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('services')
          .where('active', isEqualTo: true)
          .get();

      final Set<String> features = {};
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final serviceFeatures = List<String>.from(data['features'] ?? []);
        features.addAll(serviceFeatures);
      }

      return features.toList()..sort();
    } catch (e) {
      print('Error fetching features: $e');
      return [];
    }
  }

  // Get price range from available services
  Future<Map<String, double>> getPriceRange() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('services')
          .where('active', isEqualTo: true)
          .get();

      double minPrice = double.infinity;
      double maxPrice = 0;

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final price = (data['price'] ?? 0).toDouble();
        if (price < minPrice) minPrice = price;
        if (price > maxPrice) maxPrice = price;
      }

      return {
        'min': minPrice == double.infinity ? 0 : minPrice,
        'max': maxPrice,
      };
    } catch (e) {
      print('Error fetching price range: $e');
      return {'min': 0, 'max': 10000};
    }
  }

  // Search services with filters
  Future<List<Service>> searchServices({
    String? searchQuery,
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final collection = FirebaseFirestore.instance.collection('services');
      Query<Map<String, dynamic>> query = applyFiltersToQuery(collection);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      query = query.limit(limit);

      final snapshot = await query.get();
      List<Service> services = snapshot.docs
          .map((doc) => Service.fromJson({...doc.data(), 'id': doc.id}))
          .toList();

      // Apply client-side filters
      services = filterServices(services);

      // Apply text search if provided
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final lowercaseQuery = searchQuery.toLowerCase();
        services = services.where((service) {
          return service.name.toLowerCase().contains(lowercaseQuery) ||
              service.description.toLowerCase().contains(lowercaseQuery) ||
              service.features.any(
                (feature) => feature.toLowerCase().contains(lowercaseQuery),
              );
        }).toList();
      }

      _isLoading = false;
      notifyListeners();
      return services;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }

  // Get suggested filters based on user behavior
  Future<List<String>> getSuggestedFilters() async {
    // TODO: Implement ML-based filter suggestions
    // This could analyze user's previous searches, bookings, and preferences
    return [
      'Highly Rated (4.5+)',
      'Under KES 500',
      'Available Today',
      'Popular Choice',
      'Near You',
    ];
  }
}
