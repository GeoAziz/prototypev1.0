import 'package:equatable/equatable.dart';

class FilterCriteria extends Equatable {
  final double? minPrice;
  final double? maxPrice;
  final double? minRating;
  final String? location;
  final double? maxDistance; // in kilometers
  final List<String> selectedCategories;
  final List<String> selectedFeatures;
  final bool onlyAvailable;
  final DateTime? availableFrom;
  final DateTime? availableTo;
  final String? sortBy; // 'price', 'rating', 'distance', 'popularity'
  final bool ascending;

  const FilterCriteria({
    this.minPrice,
    this.maxPrice,
    this.minRating,
    this.location,
    this.maxDistance,
    this.selectedCategories = const [],
    this.selectedFeatures = const [],
    this.onlyAvailable = false,
    this.availableFrom,
    this.availableTo,
    this.sortBy = 'popularity',
    this.ascending = false,
  });

  FilterCriteria copyWith({
    double? minPrice,
    double? maxPrice,
    double? minRating,
    String? location,
    double? maxDistance,
    List<String>? selectedCategories,
    List<String>? selectedFeatures,
    bool? onlyAvailable,
    DateTime? availableFrom,
    DateTime? availableTo,
    String? sortBy,
    bool? ascending,
  }) {
    return FilterCriteria(
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      minRating: minRating ?? this.minRating,
      location: location ?? this.location,
      maxDistance: maxDistance ?? this.maxDistance,
      selectedCategories: selectedCategories ?? this.selectedCategories,
      selectedFeatures: selectedFeatures ?? this.selectedFeatures,
      onlyAvailable: onlyAvailable ?? this.onlyAvailable,
      availableFrom: availableFrom ?? this.availableFrom,
      availableTo: availableTo ?? this.availableTo,
      sortBy: sortBy ?? this.sortBy,
      ascending: ascending ?? this.ascending,
    );
  }

  bool get hasActiveFilters {
    return minPrice != null ||
        maxPrice != null ||
        minRating != null ||
        location != null ||
        maxDistance != null ||
        selectedCategories.isNotEmpty ||
        selectedFeatures.isNotEmpty ||
        onlyAvailable ||
        availableFrom != null ||
        availableTo != null;
  }

  int get activeFilterCount {
    int count = 0;
    if (minPrice != null || maxPrice != null) count++;
    if (minRating != null) count++;
    if (location != null || maxDistance != null) count++;
    if (selectedCategories.isNotEmpty) count++;
    if (selectedFeatures.isNotEmpty) count++;
    if (onlyAvailable) count++;
    if (availableFrom != null || availableTo != null) count++;
    return count;
  }

  Map<String, dynamic> toJson() {
    return {
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'minRating': minRating,
      'location': location,
      'maxDistance': maxDistance,
      'selectedCategories': selectedCategories,
      'selectedFeatures': selectedFeatures,
      'onlyAvailable': onlyAvailable,
      'availableFrom': availableFrom?.toIso8601String(),
      'availableTo': availableTo?.toIso8601String(),
      'sortBy': sortBy,
      'ascending': ascending,
    };
  }

  factory FilterCriteria.fromJson(Map<String, dynamic> json) {
    return FilterCriteria(
      minPrice: json['minPrice']?.toDouble(),
      maxPrice: json['maxPrice']?.toDouble(),
      minRating: json['minRating']?.toDouble(),
      location: json['location'],
      maxDistance: json['maxDistance']?.toDouble(),
      selectedCategories: List<String>.from(json['selectedCategories'] ?? []),
      selectedFeatures: List<String>.from(json['selectedFeatures'] ?? []),
      onlyAvailable: json['onlyAvailable'] ?? false,
      availableFrom: json['availableFrom'] != null
          ? DateTime.parse(json['availableFrom'])
          : null,
      availableTo: json['availableTo'] != null
          ? DateTime.parse(json['availableTo'])
          : null,
      sortBy: json['sortBy'] ?? 'popularity',
      ascending: json['ascending'] ?? false,
    );
  }

  @override
  List<Object?> get props => [
    minPrice,
    maxPrice,
    minRating,
    location,
    maxDistance,
    selectedCategories,
    selectedFeatures,
    onlyAvailable,
    availableFrom,
    availableTo,
    sortBy,
    ascending,
  ];
}
