import 'package:flutter/material.dart';
import 'package:poafix/core/theme/app_colors.dart';
import 'package:poafix/core/theme/app_text_styles.dart';

class PriceRangeFilter extends StatefulWidget {
  final double minPrice;
  final double maxPrice;
  final double rangeMin;
  final double rangeMax;
  final Function(double min, double max) onChanged;

  const PriceRangeFilter({
    super.key,
    required this.minPrice,
    required this.maxPrice,
    required this.rangeMin,
    required this.rangeMax,
    required this.onChanged,
  });

  @override
  State<PriceRangeFilter> createState() => _PriceRangeFilterState();
}

class _PriceRangeFilterState extends State<PriceRangeFilter> {
  late RangeValues _currentRange;

  @override
  void initState() {
    super.initState();
    _currentRange = RangeValues(widget.minPrice, widget.maxPrice);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Price Range', style: AppTextStyles.subtitle1),
            Text(
              'KES ${_currentRange.start.round()} - KES ${_currentRange.end.round()}',
              style: AppTextStyles.body2.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        RangeSlider(
          values: _currentRange,
          min: widget.rangeMin,
          max: widget.rangeMax,
          divisions: ((widget.rangeMax - widget.rangeMin) / 50).round(),
          activeColor: AppColors.primary,
          inactiveColor: AppColors.primary.withOpacity(0.3),
          labels: RangeLabels(
            'KES ${_currentRange.start.round()}',
            'KES ${_currentRange.end.round()}',
          ),
          onChanged: (RangeValues values) {
            setState(() {
              _currentRange = values;
            });
            widget.onChanged(values.start, values.end);
          },
        ),

        const SizedBox(height: 8),

        // Quick price presets
        Wrap(
          spacing: 8,
          children: [
            _buildPresetChip('Under 500', 0, 500),
            _buildPresetChip('500-1000', 500, 1000),
            _buildPresetChip('1000-2000', 1000, 2000),
            _buildPresetChip('2000+', 2000, widget.rangeMax),
          ],
        ),
      ],
    );
  }

  Widget _buildPresetChip(String label, double min, double max) {
    final isSelected =
        _currentRange.start <= min + 50 && _currentRange.end >= max - 50;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _currentRange = RangeValues(min, max);
          });
          widget.onChanged(min, max);
        }
      },
      selectedColor: AppColors.primary.withOpacity(0.2),
      checkmarkColor: AppColors.primary,
      labelStyle: AppTextStyles.caption.copyWith(
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
      ),
    );
  }
}
