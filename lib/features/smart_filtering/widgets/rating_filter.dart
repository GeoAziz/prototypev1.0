import 'package:flutter/material.dart';
import 'package:poafix/core/theme/app_colors.dart';
import 'package:poafix/core/theme/app_text_styles.dart';

class RatingFilter extends StatelessWidget {
  final double? selectedRating;
  final Function(double?) onChanged;

  const RatingFilter({super.key, this.selectedRating, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Minimum Rating', style: AppTextStyles.subtitle1),
        const SizedBox(height: 16),

        // Rating options
        Column(
          children: [
            _buildRatingOption(4.5, '4.5+ Stars', 'Premium quality'),
            _buildRatingOption(4.0, '4.0+ Stars', 'High quality'),
            _buildRatingOption(3.5, '3.5+ Stars', 'Good quality'),
            _buildRatingOption(3.0, '3.0+ Stars', 'Average quality'),
            _buildRatingOption(null, 'Any Rating', 'All services'),
          ],
        ),
      ],
    );
  }

  Widget _buildRatingOption(double? rating, String title, String subtitle) {
    final isSelected = selectedRating == rating;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isSelected ? AppColors.primary.withOpacity(0.1) : null,
      child: InkWell(
        onTap: () => onChanged(rating),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Star rating display
              if (rating != null) ...[
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      size: 16,
                      color: Colors.amber[600],
                    );
                  }),
                ),
                const SizedBox(width: 8),
              ] else ...[
                Icon(
                  Icons.star_outline,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
              ],

              // Title and subtitle
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
                    Text(
                      subtitle,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Selection indicator
              if (isSelected)
                Icon(Icons.check_circle, color: AppColors.primary, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
