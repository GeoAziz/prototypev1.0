import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProviderFilter {
  final String? specialization;
  final double? minRating;
  final double? maxPrice;
  final bool? availableOnly;

  const ProviderFilter({
    this.specialization,
    this.minRating,
    this.maxPrice,
    this.availableOnly,
  });
}

class ProviderFilterWidget extends ConsumerStatefulWidget {
  final Function(ProviderFilter) onFilterChanged;

  const ProviderFilterWidget({super.key, required this.onFilterChanged});

  @override
  ConsumerState<ProviderFilterWidget> createState() =>
      _ProviderFilterWidgetState();
}

class _ProviderFilterWidgetState extends ConsumerState<ProviderFilterWidget> {
  String? _specialization;
  double? _minRating;
  double? _maxPrice;
  bool _availableOnly = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter Providers',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Specialization'),
              items: [
                DropdownMenuItem(value: null, child: Text('Any')),
                DropdownMenuItem(value: 'Plumbing', child: Text('Plumbing')),
                DropdownMenuItem(
                  value: 'Electrical',
                  child: Text('Electrical'),
                ),
                DropdownMenuItem(value: 'Cleaning', child: Text('Cleaning')),
                DropdownMenuItem(value: 'Painting', child: Text('Painting')),
              ],
              value: _specialization,
              onChanged: (value) {
                setState(() => _specialization = value);
                _notifyChange();
              },
            ),
            const SizedBox(height: 16),
            Slider(
              label: 'Min Rating: ${_minRating?.toStringAsFixed(1) ?? 'Any'}',
              min: 0,
              max: 5,
              divisions: 10,
              value: _minRating ?? 0,
              onChanged: (value) {
                setState(() => _minRating = value == 0 ? null : value);
                _notifyChange();
              },
            ),
            const SizedBox(height: 16),
            Slider(
              label: 'Max Price: ${_maxPrice?.toStringAsFixed(0) ?? 'Any'}',
              min: 0,
              max: 10000,
              divisions: 20,
              value: _maxPrice ?? 0,
              onChanged: (value) {
                setState(() => _maxPrice = value == 0 ? null : value);
                _notifyChange();
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Available Only'),
              value: _availableOnly,
              onChanged: (value) {
                setState(() => _availableOnly = value);
                _notifyChange();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _notifyChange() {
    widget.onFilterChanged(
      ProviderFilter(
        specialization: _specialization,
        minRating: _minRating,
        maxPrice: _maxPrice,
        availableOnly: _availableOnly,
      ),
    );
  }
}
