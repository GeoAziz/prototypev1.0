import 'package:flutter/material.dart';
import 'package:poafix/core/theme/app_colors.dart';
import 'package:poafix/core/theme/app_text_styles.dart';

class CategoryFilter extends StatefulWidget {
  final List<String> availableCategories;
  final List<String> selectedCategories;
  final Function(List<String>) onChanged;

  const CategoryFilter({
    super.key,
    required this.availableCategories,
    required this.selectedCategories,
    required this.onChanged,
  });

  @override
  State<CategoryFilter> createState() => _CategoryFilterState();
}

class _CategoryFilterState extends State<CategoryFilter> {
  late List<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = List.from(widget.selectedCategories);
  }

  void _toggleCategory(String category) {
    setState(() {
      if (_selected.contains(category)) {
        _selected.remove(category);
      } else {
        _selected.add(category);
      }
    });
    widget.onChanged(_selected);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Categories', style: AppTextStyles.subtitle1),
            if (_selected.isNotEmpty)
              TextButton(
                onPressed: () {
                  setState(() {
                    _selected.clear();
                  });
                  widget.onChanged(_selected);
                },
                child: Text(
                  'Clear All',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),

        if (_selected.isNotEmpty) ...[
          Text(
            '${_selected.length} selected',
            style: AppTextStyles.caption.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: 8),
        ],

        // Category chips
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.availableCategories.map((category) {
            final isSelected = _selected.contains(category);
            return FilterChip(
              label: Text(_formatCategoryName(category)),
              selected: isSelected,
              onSelected: (selected) => _toggleCategory(category),
              selectedColor: AppColors.primary.withOpacity(0.2),
              checkmarkColor: AppColors.primary,
              labelStyle: AppTextStyles.body2.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
              side: BorderSide(
                color: isSelected ? AppColors.primary : Colors.grey.shade300,
              ),
            );
          }).toList(),
        ),

        if (widget.availableCategories.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Loading categories...',
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
      ],
    );
  }

  String _formatCategoryName(String categoryId) {
    // Convert category ID to display name
    // This could be enhanced with a proper mapping or API call
    return categoryId
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}
