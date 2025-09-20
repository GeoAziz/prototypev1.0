import 'package:flutter/material.dart';
import 'package:poafix/core/theme/app_colors.dart';
import 'package:poafix/core/theme/app_text_styles.dart';

class LocationFilter extends StatefulWidget {
  final String? location;
  final double? maxDistance;
  final Function(String?) onLocationChanged;
  final Function(double?) onDistanceChanged;

  const LocationFilter({
    super.key,
    this.location,
    this.maxDistance,
    required this.onLocationChanged,
    required this.onDistanceChanged,
  });

  @override
  State<LocationFilter> createState() => _LocationFilterState();
}

class _LocationFilterState extends State<LocationFilter> {
  final TextEditingController _locationController = TextEditingController();
  double? _selectedDistance;

  @override
  void initState() {
    super.initState();
    _locationController.text = widget.location ?? '';
    _selectedDistance = widget.maxDistance;
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Location & Distance', style: AppTextStyles.subtitle1),
        const SizedBox(height: 16),

        // Location input
        TextFormField(
          controller: _locationController,
          decoration: InputDecoration(
            labelText: 'Enter location',
            hintText: 'e.g., Nairobi, Westlands',
            prefixIcon: const Icon(Icons.location_on),
            suffixIcon: _locationController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _locationController.clear();
                      widget.onLocationChanged(null);
                    },
                  )
                : IconButton(
                    icon: const Icon(Icons.my_location),
                    onPressed: _useCurrentLocation,
                  ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.primary),
            ),
          ),
          onChanged: (value) {
            widget.onLocationChanged(value.isEmpty ? null : value);
          },
        ),

        const SizedBox(height: 16),

        // Distance filter
        if (_locationController.text.isNotEmpty) ...[
          Text('Maximum Distance', style: AppTextStyles.body1),
          const SizedBox(height: 8),

          Text(
            _selectedDistance != null
                ? 'Within ${_selectedDistance!.toStringAsFixed(0)} km'
                : 'Any distance',
            style: AppTextStyles.body2.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),

          Slider(
            value: _selectedDistance ?? 50,
            min: 1,
            max: 50,
            divisions: 49,
            activeColor: AppColors.primary,
            inactiveColor: AppColors.primary.withOpacity(0.3),
            label: _selectedDistance != null
                ? '${_selectedDistance!.toStringAsFixed(0)} km'
                : 'Any',
            onChanged: (value) {
              setState(() {
                _selectedDistance = value;
              });
              widget.onDistanceChanged(value);
            },
          ),

          // Distance presets
          Wrap(
            spacing: 8,
            children: [
              _buildDistanceChip('1 km', 1),
              _buildDistanceChip('5 km', 5),
              _buildDistanceChip('10 km', 10),
              _buildDistanceChip('25 km', 25),
              _buildDistanceChip('Any', null),
            ],
          ),
        ],

        // Location suggestions (could be enhanced with real location service)
        if (_locationController.text.isEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'Popular Areas',
            style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              'Nairobi CBD',
              'Westlands',
              'Karen',
              'Kilimani',
              'Lavington',
              'Kileleshwa',
            ].map((location) => _buildLocationChip(location)).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildDistanceChip(String label, double? distance) {
    final isSelected = _selectedDistance == distance;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedDistance = distance;
          });
          widget.onDistanceChanged(distance);
        }
      },
      selectedColor: AppColors.primary.withOpacity(0.2),
      checkmarkColor: AppColors.primary,
      labelStyle: AppTextStyles.caption.copyWith(
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
      ),
    );
  }

  Widget _buildLocationChip(String location) {
    return ActionChip(
      label: Text(location),
      onPressed: () {
        _locationController.text = location;
        widget.onLocationChanged(location);
      },
      backgroundColor: AppColors.primary.withOpacity(0.1),
      labelStyle: AppTextStyles.caption.copyWith(color: AppColors.primary),
    );
  }

  void _useCurrentLocation() {
    // TODO: Implement geolocation service
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Getting current location...'),
        duration: Duration(seconds: 2),
      ),
    );

    // Simulate getting current location
    Future.delayed(const Duration(seconds: 2), () {
      _locationController.text = 'Current Location';
      widget.onLocationChanged('Current Location');
    });
  }
}
