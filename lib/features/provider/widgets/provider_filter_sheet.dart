import 'package:flutter/material.dart';
import '../../../core/enums/service_category.dart';
import '../models/filter_options.dart';

class ProviderFilterSheet extends StatefulWidget {
  final FilterOptions initialFilters;
  final Function(FilterOptions) onApplyFilters;
  final List<String> availableSpecializations;
  final double maxPrice;

  const ProviderFilterSheet({
    Key? key,
    required this.initialFilters,
    required this.onApplyFilters,
    required this.availableSpecializations,
    required this.maxPrice,
  }) : super(key: key);

  @override
  State<ProviderFilterSheet> createState() => _ProviderFilterSheetState();
}

class _ProviderFilterSheetState extends State<ProviderFilterSheet> {
  late FilterOptions _currentFilters;

  @override
  void initState() {
    super.initState();
    _currentFilters = widget.initialFilters;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).canvasColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        _currentFilters = widget.initialFilters;
                        setState(() {});
                      },
                      child: const Text('Reset'),
                    ),
                    Text(
                      'Filter Providers',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    TextButton(
                      onPressed: () {
                        widget.onApplyFilters(_currentFilters);
                        Navigator.pop(context);
                      },
                      child: const Text('Apply'),
                    ),
                  ],
                ),
              ),

              // Filter options
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Price Range
                    Text(
                      'Price Range',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    RangeSlider(
                      values:
                          _currentFilters.priceRange ??
                          const RangeValues(0, double.infinity),
                      max: widget.maxPrice,
                      divisions: 100,
                      labels: RangeLabels(
                        '\$${_currentFilters.priceRange?.start.toStringAsFixed(0) ?? '0'}',
                        '\$${_currentFilters.priceRange?.end.toStringAsFixed(0) ?? 'Max'}',
                      ),
                      onChanged: (values) {
                        setState(() {
                          _currentFilters = _currentFilters.copyWith(
                            priceRange: values,
                          );
                        });
                      },
                    ),

                    const Divider(height: 32),

                    // Rating Filter
                    Text(
                      'Minimum Rating',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Slider(
                      value: _currentFilters.minRating ?? 0,
                      max: 5,
                      divisions: 10,
                      label:
                          '${_currentFilters.minRating?.toStringAsFixed(1) ?? '0'}⭐',
                      onChanged: (value) {
                        setState(() {
                          _currentFilters = _currentFilters.copyWith(
                            minRating: value,
                          );
                        });
                      },
                    ),

                    const Divider(height: 32),

                    // Distance Filter
                    Text(
                      'Maximum Distance',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Slider(
                      value: _currentFilters.radius ?? 10,
                      min: 1,
                      max: 50,
                      divisions: 49,
                      label:
                          '${_currentFilters.radius?.toStringAsFixed(1) ?? '10'} km',
                      onChanged: (value) {
                        setState(() {
                          _currentFilters = _currentFilters.copyWith(
                            radius: value,
                          );
                        });
                      },
                    ),

                    const Divider(height: 32),

                    // Categories
                    Text(
                      'Service Categories',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ServiceCategory.values.map((category) {
                        final isSelected =
                            _currentFilters.categories?.contains(category) ??
                            false;
                        return FilterChip(
                          label: Text(category.toString().split('.').last),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              final categories = List<ServiceCategory>.from(
                                _currentFilters.categories ?? [],
                              );
                              if (selected) {
                                categories.add(category);
                              } else {
                                categories.remove(category);
                              }
                              _currentFilters = _currentFilters.copyWith(
                                categories: categories,
                              );
                            });
                          },
                        );
                      }).toList(),
                    ),

                    const Divider(height: 32),

                    // Specializations
                    Text(
                      'Specializations',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.availableSpecializations.map((spec) {
                        final isSelected =
                            _currentFilters.specializationTags?.contains(
                              spec,
                            ) ??
                            false;
                        return FilterChip(
                          label: Text(spec),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              final tags = List<String>.from(
                                _currentFilters.specializationTags ?? [],
                              );
                              if (selected) {
                                tags.add(spec);
                              } else {
                                tags.remove(spec);
                              }
                              _currentFilters = _currentFilters.copyWith(
                                specializationTags: tags,
                              );
                            });
                          },
                        );
                      }).toList(),
                    ),

                    const Divider(height: 32),

                    // Availability Toggle
                    SwitchListTile(
                      title: const Text('Show Only Available'),
                      value: _currentFilters.onlyAvailable ?? false,
                      onChanged: (value) {
                        setState(() {
                          _currentFilters = _currentFilters.copyWith(
                            onlyAvailable: value,
                          );
                        });
                      },
                    ),

                    // Verified Toggle
                    SwitchListTile(
                      title: const Text('Show Only Verified'),
                      value: _currentFilters.verifiedOnly ?? false,
                      onChanged: (value) {
                        setState(() {
                          _currentFilters = _currentFilters.copyWith(
                            verifiedOnly: value,
                          );
                        });
                      },
                    ),

                    const Divider(height: 32),

                    // Sort Options
                    Text(
                      'Sort By',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    ...SortOption.values.map((option) {
                      return RadioListTile<SortOption>(
                        title: Text(_getSortOptionLabel(option)),
                        value: option,
                        groupValue: _currentFilters.sortBy,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _currentFilters = _currentFilters.copyWith(
                                sortBy: value,
                              );
                            });
                          }
                        },
                      );
                    }).toList(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getSortOptionLabel(SortOption option) {
    switch (option) {
      case SortOption.rating:
        return 'Highest Rated';
      case SortOption.distance:
        return 'Nearest First';
      case SortOption.priceHighToLow:
        return 'Price: High to Low';
      case SortOption.priceLowToHigh:
        return 'Price: Low to High';
      case SortOption.reviewCount:
        return 'Most Reviewed';
      case SortOption.newest:
        return 'Newest First';
    }
  }
}
