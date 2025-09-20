import 'package:flutter/material.dart';
import '../../../core/enums/service_category.dart';

class ProviderFilters extends StatelessWidget {
  final ServiceCategory? selectedCategory;
  final double selectedRadius;
  final Function(ServiceCategory?) onCategoryChanged;
  final Function(double) onRadiusChanged;
  final String? searchQuery;
  final Function(String) onSearchChanged;

  const ProviderFilters({
    Key? key,
    this.selectedCategory,
    required this.selectedRadius,
    required this.onCategoryChanged,
    required this.onRadiusChanged,
    this.searchQuery,
    required this.onSearchChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextFormField(
            initialValue: searchQuery,
            decoration: InputDecoration(
              hintText: 'Search providers...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onChanged: onSearchChanged,
          ),
        ),

        // Category Filter
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              FilterChip(
                label: const Text('All'),
                selected: selectedCategory == null,
                onSelected: (selected) {
                  if (selected) {
                    onCategoryChanged(null);
                  }
                },
              ),
              const SizedBox(width: 8),
              ...ServiceCategory.values.map((category) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category.toString().split('.').last),
                    selected: category == selectedCategory,
                    onSelected: (selected) {
                      onCategoryChanged(selected ? category : null);
                    },
                  ),
                );
              }).toList(),
            ],
          ),
        ),

        // Radius Slider
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.radius_outlined),
                  const SizedBox(width: 8),
                  Text(
                    'Search Radius: ${selectedRadius.toStringAsFixed(1)} km',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
              Slider(
                value: selectedRadius,
                min: 1,
                max: 50,
                divisions: 49,
                label: '${selectedRadius.toStringAsFixed(1)} km',
                onChanged: onRadiusChanged,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
