import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/enums/service_category.dart';

enum ProviderSortOption {
  rating,
  distance,
  completionRate,
  priceLowest,
  priceHighest,
}

class ProviderQueryOptions {
  final GeoPoint? location;
  final double? radius;
  final List<ServiceCategory>? categories;
  final ProviderSortOption sortBy;
  final double? minRating;
  final double? maxPrice;
  final bool onlyAvailable;
  final String? searchQuery;
  final List<String>? specializationTags;
  final DateTime? availabilityDate;

  const ProviderQueryOptions({
    this.location,
    this.radius,
    this.categories,
    this.sortBy = ProviderSortOption.rating,
    this.minRating,
    this.maxPrice,
    this.onlyAvailable = false,
    this.searchQuery,
    this.specializationTags,
    this.availabilityDate,
  });

  ProviderQueryOptions copyWith({
    GeoPoint? location,
    double? radius,
    List<ServiceCategory>? categories,
    ProviderSortOption? sortBy,
    double? minRating,
    double? maxPrice,
    bool? onlyAvailable,
    String? searchQuery,
    List<String>? specializationTags,
    DateTime? availabilityDate,
  }) {
    return ProviderQueryOptions(
      location: location ?? this.location,
      radius: radius ?? this.radius,
      categories: categories ?? this.categories,
      sortBy: sortBy ?? this.sortBy,
      minRating: minRating ?? this.minRating,
      maxPrice: maxPrice ?? this.maxPrice,
      onlyAvailable: onlyAvailable ?? this.onlyAvailable,
      searchQuery: searchQuery ?? this.searchQuery,
      specializationTags: specializationTags ?? this.specializationTags,
      availabilityDate: availabilityDate ?? this.availabilityDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location': location,
      'radius': radius,
      'categories': categories?.map((e) => e.toString()).toList(),
      'sortBy': sortBy.toString(),
      'minRating': minRating,
      'maxPrice': maxPrice,
      'onlyAvailable': onlyAvailable,
      'searchQuery': searchQuery,
      'specializationTags': specializationTags,
      'availabilityDate': availabilityDate?.toIso8601String(),
    };
  }
}
