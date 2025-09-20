import 'package:flutter/material.dart';
import 'package:poafix/core/theme/app_colors.dart';
import 'package:poafix/core/theme/app_text_styles.dart';
import 'package:poafix/features/smart_filtering/models/filter_criteria.dart';
import 'package:poafix/features/smart_filtering/services/smart_filtering_service.dart';
import 'package:poafix/features/smart_filtering/widgets/price_range_filter.dart';
import 'package:poafix/features/smart_filtering/widgets/rating_filter.dart';
import 'package:poafix/features/smart_filtering/widgets/category_filter.dart';
import 'package:poafix/features/smart_filtering/widgets/feature_filter.dart';
import 'package:poafix/features/smart_filtering/widgets/location_filter.dart';
import 'package:poafix/features/smart_filtering/widgets/availability_filter.dart';
import 'package:poafix/features/smart_filtering/widgets/sort_options.dart';

class SmartFilteringScreen extends StatefulWidget {
  final FilterCriteria? initialCriteria;
  final Function(FilterCriteria)? onFiltersChanged;

  const SmartFilteringScreen({
    super.key,
    this.initialCriteria,
    this.onFiltersChanged,
  });

  @override
  State<SmartFilteringScreen> createState() => _SmartFilteringScreenState();
}

class _SmartFilteringScreenState extends State<SmartFilteringScreen>
    with TickerProviderStateMixin {
  late FilterCriteria _criteria;
  final SmartFilteringService _filteringService = SmartFilteringService();
  late TabController _tabController;

  // Filter options data
  List<String> _availableCategories = [];
  List<String> _availableFeatures = [];
  Map<String, double> _priceRange = {'min': 0, 'max': 10000};
  List<String> _suggestedFilters = [];

  @override
  void initState() {
    super.initState();
    _criteria = widget.initialCriteria ?? _filteringService.currentCriteria;
    _tabController = TabController(length: 3, vsync: this);
    _loadFilterOptions();
  }

  Future<void> _loadFilterOptions() async {
    final categories = await _filteringService.getAvailableCategories();
    final features = await _filteringService.getAvailableFeatures();
    final priceRange = await _filteringService.getPriceRange();
    final suggested = await _filteringService.getSuggestedFilters();

    setState(() {
      _availableCategories = categories;
      _availableFeatures = features;
      _priceRange = priceRange;
      _suggestedFilters = suggested;
    });
  }

  void _updateCriteria(FilterCriteria newCriteria) {
    setState(() {
      _criteria = newCriteria;
    });
  }

  void _applyFilters() {
    _filteringService.updateCriteria(_criteria);
    widget.onFiltersChanged?.call(_criteria);
    Navigator.of(context).pop(_criteria);
  }

  void _clearFilters() {
    setState(() {
      _criteria = const FilterCriteria();
    });
  }

  void _resetToDefaults() {
    setState(() {
      _criteria = const FilterCriteria();
    });
    _filteringService.clearFilters();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Filters'),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _clearFilters,
            child: Text(
              'Clear',
              style: AppTextStyles.subtitle1.copyWith(color: AppColors.primary),
            ),
          ),
          TextButton(
            onPressed: _resetToDefaults,
            child: Text(
              'Reset',
              style: AppTextStyles.subtitle1.copyWith(color: AppColors.primary),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Filters', icon: Icon(Icons.filter_list)),
            Tab(text: 'Sort', icon: Icon(Icons.sort)),
            Tab(text: 'Quick', icon: Icon(Icons.flash_on)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Active filters summary
          if (_criteria.hasActiveFilters)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: AppColors.primaryLight.withOpacity(0.1),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${_criteria.activeFilterCount} filter(s) active',
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _clearFilters,
                    child: Text(
                      'Clear All',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFiltersTab(),
                _buildSortTab(),
                _buildQuickFiltersTab(),
              ],
            ),
          ),

          // Apply button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _applyFilters,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text('Apply Filters', style: AppTextStyles.subtitle1),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Price Range Filter
          PriceRangeFilter(
            minPrice: _criteria.minPrice ?? _priceRange['min']!,
            maxPrice: _criteria.maxPrice ?? _priceRange['max']!,
            rangeMin: _priceRange['min']!,
            rangeMax: _priceRange['max']!,
            onChanged: (min, max) {
              _updateCriteria(_criteria.copyWith(minPrice: min, maxPrice: max));
            },
          ),

          const SizedBox(height: 24),

          // Rating Filter
          RatingFilter(
            selectedRating: _criteria.minRating,
            onChanged: (rating) {
              _updateCriteria(_criteria.copyWith(minRating: rating));
            },
          ),

          const SizedBox(height: 24),

          // Category Filter
          if (_availableCategories.isNotEmpty)
            CategoryFilter(
              availableCategories: _availableCategories,
              selectedCategories: _criteria.selectedCategories,
              onChanged: (categories) {
                _updateCriteria(
                  _criteria.copyWith(selectedCategories: categories),
                );
              },
            ),

          const SizedBox(height: 24),

          // Feature Filter
          if (_availableFeatures.isNotEmpty)
            FeatureFilter(
              availableFeatures: _availableFeatures,
              selectedFeatures: _criteria.selectedFeatures,
              onChanged: (features) {
                _updateCriteria(_criteria.copyWith(selectedFeatures: features));
              },
            ),

          const SizedBox(height: 24),

          // Location Filter
          LocationFilter(
            location: _criteria.location,
            maxDistance: _criteria.maxDistance,
            onLocationChanged: (location) {
              _updateCriteria(_criteria.copyWith(location: location));
            },
            onDistanceChanged: (distance) {
              _updateCriteria(_criteria.copyWith(maxDistance: distance));
            },
          ),

          const SizedBox(height: 24),

          // Availability Filter
          AvailabilityFilter(
            onlyAvailable: _criteria.onlyAvailable,
            availableFrom: _criteria.availableFrom,
            availableTo: _criteria.availableTo,
            onAvailabilityChanged: (onlyAvailable) {
              _updateCriteria(_criteria.copyWith(onlyAvailable: onlyAvailable));
            },
            onDateRangeChanged: (from, to) {
              _updateCriteria(
                _criteria.copyWith(availableFrom: from, availableTo: to),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSortTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: SortOptions(
        sortBy: _criteria.sortBy ?? 'popularity',
        ascending: _criteria.ascending,
        onSortChanged: (sortBy, ascending) {
          _updateCriteria(
            _criteria.copyWith(sortBy: sortBy, ascending: ascending),
          );
        },
      ),
    );
  }

  Widget _buildQuickFiltersTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick Filters', style: AppTextStyles.headline3),
          const SizedBox(height: 8),
          Text(
            'Tap to quickly apply common filter combinations',
            style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),

          // Suggested filters
          ...(_suggestedFilters.map((suggestion) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Icon(Icons.flash_on, color: AppColors.primary),
                title: Text(suggestion),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _applyQuickFilter(suggestion),
              ),
            );
          }).toList()),

          const SizedBox(height: 16),

          // Preset filter combinations
          Text('Popular Combinations', style: AppTextStyles.subtitle1),
          const SizedBox(height: 8),

          _buildQuickFilterCard(
            'Best Value',
            'High rating with affordable pricing',
            Icons.star,
            () => _updateCriteria(
              _criteria.copyWith(
                minRating: 4.0,
                maxPrice: 1000,
                sortBy: 'price',
                ascending: true,
              ),
            ),
          ),

          _buildQuickFilterCard(
            'Premium Services',
            'Top-rated providers with premium features',
            Icons.diamond,
            () => _updateCriteria(
              _criteria.copyWith(
                minRating: 4.5,
                sortBy: 'rating',
                ascending: false,
              ),
            ),
          ),

          _buildQuickFilterCard(
            'Quick Booking',
            'Available now with instant confirmation',
            Icons.bolt,
            () => _updateCriteria(
              _criteria.copyWith(onlyAvailable: true, sortBy: 'popularity'),
            ),
          ),

          _buildQuickFilterCard(
            'Budget Friendly',
            'Affordable options under KES 500',
            Icons.savings,
            () => _updateCriteria(
              _criteria.copyWith(
                maxPrice: 500,
                sortBy: 'price',
                ascending: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickFilterCard(
    String title,
    String description,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.subtitle1),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _applyQuickFilter(String suggestion) {
    switch (suggestion) {
      case 'Highly Rated (4.5+)':
        _updateCriteria(
          _criteria.copyWith(
            minRating: 4.5,
            sortBy: 'rating',
            ascending: false,
          ),
        );
        break;
      case 'Under KES 500':
        _updateCriteria(
          _criteria.copyWith(maxPrice: 500, sortBy: 'price', ascending: true),
        );
        break;
      case 'Available Today':
        _updateCriteria(
          _criteria.copyWith(
            onlyAvailable: true,
            availableFrom: DateTime.now(),
            availableTo: DateTime.now().add(const Duration(days: 1)),
          ),
        );
        break;
      case 'Popular Choice':
        _updateCriteria(
          _criteria.copyWith(sortBy: 'popularity', ascending: false),
        );
        break;
      case 'Near You':
        _updateCriteria(_criteria.copyWith(maxDistance: 5.0));
        break;
    }
  }
}
