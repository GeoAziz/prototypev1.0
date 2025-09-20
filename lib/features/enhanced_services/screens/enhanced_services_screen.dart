import 'package:flutter/material.dart';
import 'package:poafix/core/theme/app_colors.dart';
import 'package:poafix/core/theme/app_text_styles.dart';
import 'package:poafix/features/smart_filtering/services/smart_filtering_service.dart';
import 'package:poafix/features/smart_filtering/models/filter_criteria.dart';
import 'package:poafix/features/service_comparison/widgets/comparison_manager.dart';
import 'package:poafix/core/models/service.dart';
import 'package:poafix/core/widgets/service_card.dart';
import 'package:go_router/go_router.dart';

class EnhancedServicesScreen extends StatefulWidget {
  final String? categoryId;
  final String? searchQuery;
  final FilterCriteria? initialFilters;

  const EnhancedServicesScreen({
    super.key,
    this.categoryId,
    this.searchQuery,
    this.initialFilters,
  });

  @override
  State<EnhancedServicesScreen> createState() => _EnhancedServicesScreenState();
}

class _EnhancedServicesScreenState extends State<EnhancedServicesScreen> {
  final SmartFilteringService _filteringService = SmartFilteringService();
  final TextEditingController _searchController = TextEditingController();

  List<Service> _services = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.initialFilters != null) {
      _filteringService.updateCriteria(widget.initialFilters!);
    }
    if (widget.searchQuery != null) {
      _searchController.text = widget.searchQuery!;
    }
    _loadServices();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadServices() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final services = await _filteringService.searchServices(
        searchQuery: _searchController.text.isEmpty
            ? null
            : _searchController.text,
        limit: 50,
      );

      setState(() {
        _services = services;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onFiltersChanged(FilterCriteria criteria) {
    _filteringService.updateCriteria(criteria);
    _loadServices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enhanced Services'),
        elevation: 0,
        actions: [
          // Active filters indicator
          if (_filteringService.currentCriteria.hasActiveFilters)
            Container(
              margin: const EdgeInsets.only(right: 8),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_filteringService.currentCriteria.activeFilterCount}',
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

          // Filter button
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () async {
              final result = await context.push(
                '/smart-filters',
                extra: _filteringService.currentCriteria,
              );
              if (result is FilterCriteria) {
                _onFiltersChanged(result);
              }
            },
          ),

          // Search button
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: ServiceSearchDelegate(
                  filteringService: _filteringService,
                ),
              );
            },
          ),
        ],
      ),

      // Comparison floating button
      floatingActionButton: const ComparisonFloatingButton(),

      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade50,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search services...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _loadServices();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onSubmitted: (value) => _loadServices(),
            ),
          ),

          // Active filters summary
          if (_filteringService.currentCriteria.hasActiveFilters)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppColors.primary.withOpacity(0.1),
              child: Row(
                children: [
                  Icon(Icons.filter_list, size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _buildFilterSummary(),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _filteringService.clearFilters();
                      _loadServices();
                    },
                    child: Text(
                      'Clear',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Services list
          Expanded(child: _buildServicesContent()),
        ],
      ),
    );
  }

  Widget _buildServicesContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error loading services', style: AppTextStyles.headline3),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: AppTextStyles.body2.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadServices,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_services.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No services found',
              style: AppTextStyles.headline3.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters or search terms',
              style: AppTextStyles.body2.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _filteringService.clearFilters();
                _searchController.clear();
                _loadServices();
              },
              child: const Text('Clear All Filters'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadServices,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.75,
        ),
        itemCount: _services.length,
        itemBuilder: (context, index) {
          final service = _services[index];
          return ServiceCard(
            service: service,
            onTap: () => context.push('/service/${service.id}'),
            showCompareButton: true,
          );
        },
      ),
    );
  }

  String _buildFilterSummary() {
    final criteria = _filteringService.currentCriteria;
    final List<String> filters = [];

    if (criteria.minPrice != null || criteria.maxPrice != null) {
      if (criteria.minPrice != null && criteria.maxPrice != null) {
        filters.add(
          'KES ${criteria.minPrice!.round()}-${criteria.maxPrice!.round()}',
        );
      } else if (criteria.minPrice != null) {
        filters.add('Min KES ${criteria.minPrice!.round()}');
      } else {
        filters.add('Max KES ${criteria.maxPrice!.round()}');
      }
    }

    if (criteria.minRating != null) {
      filters.add('${criteria.minRating}+ stars');
    }

    if (criteria.selectedCategories.isNotEmpty) {
      filters.add('${criteria.selectedCategories.length} categories');
    }

    if (criteria.selectedFeatures.isNotEmpty) {
      filters.add('${criteria.selectedFeatures.length} features');
    }

    if (criteria.onlyAvailable) {
      filters.add('Available now');
    }

    if (criteria.location != null) {
      filters.add('Near ${criteria.location}');
    }

    return filters.join(' • ');
  }
}

// Custom search delegate for services
class ServiceSearchDelegate extends SearchDelegate<String> {
  final SmartFilteringService filteringService;

  ServiceSearchDelegate({required this.filteringService});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return const Center(child: Text('Search for services...'));
    }
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    return FutureBuilder<List<Service>>(
      future: filteringService.searchServices(searchQuery: query, limit: 20),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final services = snapshot.data ?? [];

        if (services.isEmpty) {
          return const Center(child: Text('No services found'));
        }

        return ListView.builder(
          itemCount: services.length,
          itemBuilder: (context, index) {
            final service = services[index];
            return ServiceCard(
              service: service,
              isCompact: true,
              onTap: () {
                close(context, service.name);
                context.push('/service/${service.id}');
              },
            );
          },
        );
      },
    );
  }
}
