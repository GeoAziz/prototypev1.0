import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class RadiusSlider extends StatelessWidget {
  final double radius;
  final Function(double) onChanged;

  const RadiusSlider({Key? key, required this.radius, required this.onChanged})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Search Radius'),
                Text('${radius.toStringAsFixed(1)} km'),
              ],
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppColors.primary,
                inactiveTrackColor: AppColors.primary.withOpacity(0.2),
                thumbColor: AppColors.primary,
                overlayColor: AppColors.primary.withOpacity(0.1),
                trackHeight: 4.0,
              ),
              child: Slider(
                value: radius,
                min: 1.0,
                max: 50.0,
                onChanged: (value) {
                  onChanged(value);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
