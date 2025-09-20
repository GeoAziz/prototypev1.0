import 'package:flutter/material.dart' show RangeValues;
import '../../../core/enums/service_category.dart';

class FilterOptions {
  final RangeValues? priceRange;
  final double? minRating;
  final double? radius;
  final bool? onlyAvailable;
  final List<ServiceCategory>? categories;
  final List<String>? specializationTags;
  final String? searchQuery;
  final bool? verifiedOnly;
  final SortOption sortBy;

  const FilterOptions({
    this.priceRange,
    this.minRating,
    this.radius,
    this.onlyAvailable,
    this.categories,
    this.specializationTags,
    this.searchQuery,
    this.verifiedOnly,
    this.sortBy = SortOption.rating,
  });

  FilterOptions copyWith({
    RangeValues? priceRange,
    double? minRating,
    double? radius,
    bool? onlyAvailable,
    List<ServiceCategory>? categories,
    List<String>? specializationTags,
    String? searchQuery,
    bool? verifiedOnly,
    SortOption? sortBy,
  }) {
    return FilterOptions(
      priceRange: priceRange ?? this.priceRange,
      minRating: minRating ?? this.minRating,
      radius: radius ?? this.radius,
      onlyAvailable: onlyAvailable ?? this.onlyAvailable,
      categories: categories ?? this.categories,
      specializationTags: specializationTags ?? this.specializationTags,
      searchQuery: searchQuery ?? this.searchQuery,
      verifiedOnly: verifiedOnly ?? this.verifiedOnly,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'priceRange': priceRange != null
          ? {'min': priceRange!.start, 'max': priceRange!.end}
          : null,
      'minRating': minRating,
      'radius': radius,
      'onlyAvailable': onlyAvailable,
      'categories': categories?.map((e) => e.toString()).toList(),
      'specializationTags': specializationTags,
      'searchQuery': searchQuery,
      'verifiedOnly': verifiedOnly,
      'sortBy': sortBy.toString(),
    };
  }

  factory FilterOptions.fromJson(Map<String, dynamic> json) {
    return FilterOptions(
      priceRange: json['priceRange'] != null
          ? RangeValues(
              json['priceRange']['min'] as double,
              json['priceRange']['max'] as double,
            )
          : null,
      minRating: json['minRating'] as double?,
      radius: json['radius'] as double?,
      onlyAvailable: json['onlyAvailable'] as bool?,
      categories: (json['categories'] as List<dynamic>?)?.map((e) {
        return ServiceCategory.values.firstWhere(
          (cat) => cat.toString() == e,
          orElse: () => ServiceCategory.other,
        );
      }).toList(),
      specializationTags: (json['specializationTags'] as List<dynamic>?)
          ?.cast<String>(),
      searchQuery: json['searchQuery'] as String?,
      verifiedOnly: json['verifiedOnly'] as bool?,
      sortBy: SortOption.values.firstWhere(
        (e) => e.toString() == json['sortBy'],
        orElse: () => SortOption.rating,
      ),
    );
  }
}

enum SortOption {
  rating,
  distance,
  priceHighToLow,
  priceLowToHigh,
  reviewCount,
  newest,
}
