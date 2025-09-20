import 'package:flutter/material.dart';
import 'package:poafix/core/theme/app_colors.dart';
import 'package:poafix/core/theme/app_text_styles.dart';

class FeatureFilter extends StatefulWidget {
  final List<String> availableFeatures;
  final List<String> selectedFeatures;
  final Function(List<String>) onChanged;

  const FeatureFilter({
    super.key,
    required this.availableFeatures,
    required this.selectedFeatures,
    required this.onChanged,
  });

  @override
  State<FeatureFilter> createState() => _FeatureFilterState();
}

class _FeatureFilterState extends State<FeatureFilter> {
  late List<String> _selected;
  bool _showAll = false;

  @override
  void initState() {
    super.initState();
    _selected = List.from(widget.selectedFeatures);
  }

  void _toggleFeature(String feature) {
    setState(() {
      if (_selected.contains(feature)) {
        _selected.remove(feature);
      } else {
        _selected.add(feature);
      }
    });
    widget.onChanged(_selected);
  }

  @override
  Widget build(BuildContext context) {
    final displayFeatures = _showAll
        ? widget.availableFeatures
        : widget.availableFeatures.take(6).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Features', style: AppTextStyles.subtitle1),
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
            '${_selected.length} feature(s) selected',
            style: AppTextStyles.caption.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: 8),
        ],

        // Feature grid
        if (widget.availableFeatures.isNotEmpty) ...[
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: displayFeatures.length,
            itemBuilder: (context, index) {
              final feature = displayFeatures[index];
              final isSelected = _selected.contains(feature);

              return InkWell(
                onTap: () => _toggleFeature(feature),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : Colors.grey.shade300,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    color: isSelected
                        ? AppColors.primary.withOpacity(0.1)
                        : null,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected ? Icons.check_circle : Icons.circle_outlined,
                        size: 16,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          feature,
                          style: AppTextStyles.caption.copyWith(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textPrimary,
                            fontWeight: isSelected
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Show more/less button
          if (widget.availableFeatures.length > 6) ...[
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _showAll = !_showAll;
                  });
                },
                child: Text(
                  _showAll
                      ? 'Show Less'
                      : 'Show ${widget.availableFeatures.length - 6} More',
                  style: AppTextStyles.body2.copyWith(color: AppColors.primary),
                ),
              ),
            ),
          ],
        ] else ...[
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Loading features...',
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
