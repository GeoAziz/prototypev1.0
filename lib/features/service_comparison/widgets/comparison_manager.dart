import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ServiceComparisonManager {
  static final ServiceComparisonManager _instance =
      ServiceComparisonManager._internal();
  factory ServiceComparisonManager() => _instance;
  ServiceComparisonManager._internal();

  final List<String> _selectedServices = [];
  static const int maxServices = 4;

  List<String> get selectedServices => List.unmodifiable(_selectedServices);
  int get count => _selectedServices.length;
  bool get isFull => _selectedServices.length >= maxServices;
  bool get hasServices => _selectedServices.isNotEmpty;

  bool isSelected(String serviceId) => _selectedServices.contains(serviceId);

  bool addService(String serviceId) {
    if (!_selectedServices.contains(serviceId) && !isFull) {
      _selectedServices.add(serviceId);
      return true;
    }
    return false;
  }

  void removeService(String serviceId) {
    _selectedServices.remove(serviceId);
  }

  void clear() {
    _selectedServices.clear();
  }

  void navigateToComparison(BuildContext context) {
    if (hasServices) {
      context.push('/compare', extra: _selectedServices);
    }
  }
}

class ComparisonFloatingButton extends StatefulWidget {
  const ComparisonFloatingButton({super.key});

  @override
  State<ComparisonFloatingButton> createState() =>
      _ComparisonFloatingButtonState();
}

class _ComparisonFloatingButtonState extends State<ComparisonFloatingButton> {
  final ServiceComparisonManager _manager = ServiceComparisonManager();

  @override
  Widget build(BuildContext context) {
    if (!_manager.hasServices) {
      return const SizedBox.shrink();
    }

    return FloatingActionButton.extended(
      onPressed: () => _manager.navigateToComparison(context),
      icon: const Icon(Icons.compare_arrows),
      label: Text('Compare (${_manager.count})'),
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
    );
  }
}

class ComparisonButton extends StatefulWidget {
  final String serviceId;
  final VoidCallback? onChanged;

  const ComparisonButton({super.key, required this.serviceId, this.onChanged});

  @override
  State<ComparisonButton> createState() => _ComparisonButtonState();
}

class _ComparisonButtonState extends State<ComparisonButton> {
  final ServiceComparisonManager _manager = ServiceComparisonManager();

  @override
  Widget build(BuildContext context) {
    final isSelected = _manager.isSelected(widget.serviceId);
    final isFull = _manager.isFull;

    return IconButton(
      onPressed: () {
        setState(() {
          if (isSelected) {
            _manager.removeService(widget.serviceId);
          } else if (!isFull) {
            _manager.addService(widget.serviceId);
          } else {
            // Show snackbar if trying to add more than max
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'You can only compare up to ${ServiceComparisonManager.maxServices} services',
                ),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        });
        widget.onChanged?.call();
      },
      icon: Icon(
        isSelected ? Icons.remove_circle : Icons.add_circle_outline,
        color: isSelected
            ? Colors.red
            : (isFull ? Colors.grey : Theme.of(context).primaryColor),
      ),
      tooltip: isSelected
          ? 'Remove from comparison'
          : (isFull ? 'Comparison is full' : 'Add to comparison'),
    );
  }
}
