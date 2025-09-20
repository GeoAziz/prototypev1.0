import 'package:flutter/material.dart';

class SpecializationChip extends StatelessWidget {
  final String specialization;
  final bool selected;
  final VoidCallback? onTap;

  const SpecializationChip({
    super.key,
    required this.specialization,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(specialization),
      selected: selected,
      onSelected: (_) => onTap?.call(),
      selectedColor: Theme.of(context).colorScheme.primary,
      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
      labelStyle: TextStyle(
        color: selected
            ? Colors.white
            : Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}
