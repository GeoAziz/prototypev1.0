import 'package:flutter/material.dart';
import '../../../core/enums/service_category.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class MapFilters {
  final ServiceCategory? category;
  final double minRating;
  final double maxPrice;
  final bool onlyAvailable;
  final List<String> selectedServices;

  const MapFilters({
    this.category,
    this.minRating = 0.0,
    this.maxPrice = double.infinity,
    this.onlyAvailable = false,
    this.selectedServices = const [],
  });

  MapFilters copyWith({
    ServiceCategory? category,
    double? minRating,
    double? maxPrice,
    bool? onlyAvailable,
    List<String>? selectedServices,
  }) {
    return MapFilters(
      category: category ?? this.category,
      minRating: minRating ?? this.minRating,
      maxPrice: maxPrice ?? this.maxPrice,
      onlyAvailable: onlyAvailable ?? this.onlyAvailable,
      selectedServices: selectedServices ?? this.selectedServices,
    );
  }
}

class FilterBottomSheet extends StatefulWidget {
  final MapFilters initialFilters;
  final Function(MapFilters) onApplyFilters;

  const FilterBottomSheet({
    Key? key,
    required this.initialFilters,
    required this.onApplyFilters,
  }) : super(key: key);

  static Future<void> show(
    BuildContext context,
    MapFilters initialFilters,
    Function(MapFilters) onApplyFilters,
  ) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheet(
        initialFilters: initialFilters,
        onApplyFilters: onApplyFilters,
      ),
    );
  }

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late MapFilters _filters;
  final _priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filters = widget.initialFilters;
    _priceController.text = _filters.maxPrice == double.infinity
        ? ''
        : _filters.maxPrice.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 20),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Filter Providers', style: AppTextStyles.headline3),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _filters = const MapFilters();
                        _priceController.clear();
                      });
                    },
                    child: const Text('Reset'),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Category filter
                  Text(
                    'Service Category',
                    style: AppTextStyles.body1.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ServiceCategory.values.map((category) {
                      return FilterChip(
                        selected: _filters.category == category,
                        label: Text(category.displayName),
                        onSelected: (selected) {
                          setState(() {
                            _filters = _filters.copyWith(
                              category: selected ? category : null,
                            );
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Rating filter
                  Text(
                    'Minimum Rating',
                    style: AppTextStyles.body1.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: _filters.minRating,
                          min: 0,
                          max: 5,
                          divisions: 10,
                          label: _filters.minRating.toStringAsFixed(1),
                          onChanged: (value) {
                            setState(() {
                              _filters = _filters.copyWith(minRating: value);
                            });
                          },
                        ),
                      ),
                      SizedBox(
                        width: 50,
                        child: Text(
                          '${_filters.minRating.toStringAsFixed(1)} ★',
                          style: AppTextStyles.body2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Price filter
                  Text(
                    'Maximum Price (KES)',
                    style: AppTextStyles.body1.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'Enter maximum price',
                      prefixText: 'KES ',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      final price = double.tryParse(value);
                      if (price != null) {
                        setState(() {
                          _filters = _filters.copyWith(maxPrice: price);
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 24),

                  // Availability filter
                  SwitchListTile(
                    title: Text(
                      'Show Only Available Providers',
                      style: AppTextStyles.body1.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    value: _filters.onlyAvailable,
                    onChanged: (value) {
                      setState(() {
                        _filters = _filters.copyWith(onlyAvailable: value);
                      });
                    },
                  ),
                ],
              ),
            ),
            // Apply button
            Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                8,
                16,
                8 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: ElevatedButton(
                onPressed: () {
                  widget.onApplyFilters(_filters);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Apply Filters'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }
}
