import 'package:flutter/material.dart' show RangeValues;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:state_notifier/state_notifier.dart';
import '../models/filter_options.dart';
import '../../../core/enums/service_category.dart';

class ProviderFiltersState {
  final FilterOptions filters;
  final bool isLoading;
  final String? error;
  final List<String> availableSpecializations;
  final double maxPrice;

  const ProviderFiltersState({
    required this.filters,
    this.isLoading = false,
    this.error,
    this.availableSpecializations = const [],
    this.maxPrice = 1000,
  });

  ProviderFiltersState copyWith({
    FilterOptions? filters,
    bool? isLoading,
    String? error,
    List<String>? availableSpecializations,
    double? maxPrice,
  }) {
    return ProviderFiltersState(
      filters: filters ?? this.filters,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      availableSpecializations:
          availableSpecializations ?? this.availableSpecializations,
      maxPrice: maxPrice ?? this.maxPrice,
    );
  }
}

class ProviderFiltersNotifier extends StateNotifier<ProviderFiltersState> {
  ProviderFiltersNotifier()
    : super(ProviderFiltersState(filters: const FilterOptions()));

  void updateFilters(FilterOptions filters) {
    state = state.copyWith(filters: filters);
  }

  void setAvailableSpecializations(List<String> specializations) {
    state = state.copyWith(availableSpecializations: specializations);
  }

  void setMaxPrice(double maxPrice) {
    state = state.copyWith(maxPrice: maxPrice);
  }

  void setError(String? error) {
    state = state.copyWith(error: error);
  }

  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  void resetFilters() {
    state = state.copyWith(filters: const FilterOptions());
  }

  void updatePriceRange(RangeValues range) {
    state = state.copyWith(filters: state.filters.copyWith(priceRange: range));
  }

  void updateMinRating(double rating) {
    state = state.copyWith(filters: state.filters.copyWith(minRating: rating));
  }

  void updateRadius(double radius) {
    state = state.copyWith(filters: state.filters.copyWith(radius: radius));
  }

  void toggleCategory(ServiceCategory category) {
    final currentCategories = List<ServiceCategory>.from(
      state.filters.categories ?? [],
    );
    if (currentCategories.contains(category)) {
      currentCategories.remove(category);
    } else {
      currentCategories.add(category);
    }
    state = state.copyWith(
      filters: state.filters.copyWith(categories: currentCategories),
    );
  }

  void toggleSpecialization(String specialization) {
    final currentTags = List<String>.from(
      state.filters.specializationTags ?? [],
    );
    if (currentTags.contains(specialization)) {
      currentTags.remove(specialization);
    } else {
      currentTags.add(specialization);
    }
    state = state.copyWith(
      filters: state.filters.copyWith(specializationTags: currentTags),
    );
  }

  void toggleAvailability() {
    state = state.copyWith(
      filters: state.filters.copyWith(
        onlyAvailable: !(state.filters.onlyAvailable ?? false),
      ),
    );
  }

  void toggleVerified() {
    state = state.copyWith(
      filters: state.filters.copyWith(
        verifiedOnly: !(state.filters.verifiedOnly ?? false),
      ),
    );
  }

  void updateSortOption(SortOption sortBy) {
    state = state.copyWith(filters: state.filters.copyWith(sortBy: sortBy));
  }

  void updateSearchQuery(String? query) {
    state = state.copyWith(filters: state.filters.copyWith(searchQuery: query));
  }
}

// Providers
final providerFiltersProvider =
    StateNotifierProvider<ProviderFiltersNotifier, ProviderFiltersState>((ref) {
      return ProviderFiltersNotifier();
    });
