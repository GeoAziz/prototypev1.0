import 'package:flutter/material.dart';
import 'package:poafix/core/theme/app_colors.dart';
import 'package:poafix/core/theme/app_text_styles.dart';

class SortOptions extends StatelessWidget {
  final String sortBy;
  final bool ascending;
  final Function(String, bool) onSortChanged;

  const SortOptions({
    super.key,
    required this.sortBy,
    required this.ascending,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Sort Results By', style: AppTextStyles.subtitle1),
        const SizedBox(height: 16),

        // Sort options
        Column(
          children: [
            _buildSortOption(
              'popularity',
              'Popularity',
              'Most booked services first',
              Icons.trending_up,
            ),
            _buildSortOption(
              'rating',
              'Rating',
              'Highest rated services first',
              Icons.star,
            ),
            _buildSortOption(
              'price',
              'Price',
              'Sort by service price',
              Icons.attach_money,
            ),
            _buildSortOption(
              'distance',
              'Distance',
              'Closest services first',
              Icons.location_on,
            ),
            _buildSortOption(
              'newest',
              'Newest',
              'Most recently added services',
              Icons.new_releases,
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Sort order
        Text('Sort Order', style: AppTextStyles.subtitle1),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: _buildOrderOption(
                false,
                _getDescendingLabel(),
                _getDescendingDescription(),
                Icons.arrow_downward,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildOrderOption(
                true,
                _getAscendingLabel(),
                _getAscendingDescription(),
                Icons.arrow_upward,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSortOption(
    String value,
    String title,
    String description,
    IconData icon,
  ) {
    final isSelected = sortBy == value;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isSelected ? AppColors.primary.withOpacity(0.1) : null,
      child: InkWell(
        onTap: () => onSortChanged(value, ascending),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.body1.copyWith(
                        color: isSelected ? AppColors.primary : null,
                        fontWeight: isSelected ? FontWeight.w500 : null,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle, color: AppColors.primary, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderOption(
    bool isAscending,
    String title,
    String description,
    IconData icon,
  ) {
    final isSelected = ascending == isAscending;

    return Card(
      color: isSelected ? AppColors.primary.withOpacity(0.1) : null,
      child: InkWell(
        onTap: () => onSortChanged(sortBy, isAscending),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  size: 24,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: AppTextStyles.subtitle2.copyWith(
                  color: isSelected ? AppColors.primary : null,
                  fontWeight: isSelected ? FontWeight.w500 : null,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
              if (isSelected) ...[
                const SizedBox(height: 8),
                Icon(Icons.check_circle, color: AppColors.primary, size: 16),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _getDescendingLabel() {
    switch (sortBy) {
      case 'price':
        return 'High to Low';
      case 'rating':
        return 'High to Low';
      case 'popularity':
        return 'Most Popular';
      case 'distance':
        return 'Farthest First';
      case 'newest':
        return 'Newest First';
      default:
        return 'Descending';
    }
  }

  String _getDescendingDescription() {
    switch (sortBy) {
      case 'price':
        return 'Expensive first';
      case 'rating':
        return 'Best rated first';
      case 'popularity':
        return 'Most booked first';
      case 'distance':
        return 'Farthest services';
      case 'newest':
        return 'Latest additions';
      default:
        return 'Highest values first';
    }
  }

  String _getAscendingLabel() {
    switch (sortBy) {
      case 'price':
        return 'Low to High';
      case 'rating':
        return 'Low to High';
      case 'popularity':
        return 'Least Popular';
      case 'distance':
        return 'Closest First';
      case 'newest':
        return 'Oldest First';
      default:
        return 'Ascending';
    }
  }

  String _getAscendingDescription() {
    switch (sortBy) {
      case 'price':
        return 'Cheapest first';
      case 'rating':
        return 'Lower rated first';
      case 'popularity':
        return 'Less booked first';
      case 'distance':
        return 'Nearest services';
      case 'newest':
        return 'Older services';
      default:
        return 'Lowest values first';
    }
  }
}
