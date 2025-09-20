import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/provider_specialization.dart';
import '../providers/specialization_provider.dart';

class SpecializationSelector extends ConsumerWidget {
  final List<String> selectedSpecializationIds;
  final Function(List<String>) onSpecializationsChanged;

  const SpecializationSelector({
    Key? key,
    required this.selectedSpecializationIds,
    required this.onSpecializationsChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final specializations = ref.watch(specializationStateProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Specializations', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        specializations.when(
          data: (data) {
            if (data.isEmpty) {
              return const Text('No specializations available');
            }

            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: data.map((specialization) {
                final isSelected = selectedSpecializationIds.contains(
                  specialization.id,
                );
                return FilterChip(
                  selected: isSelected,
                  onSelected: (selected) {
                    List<String> updatedIds = List.from(
                      selectedSpecializationIds,
                    );
                    if (selected) {
                      updatedIds.add(specialization.id);
                    } else {
                      updatedIds.remove(specialization.id);
                    }
                    onSpecializationsChanged(updatedIds);
                  },
                  label: Text(specialization.name),
                  // avatar: specialization.isVerified
                  //     ? const Icon(Icons.verified, size: 16)
                  //     : null,
                );
              }).toList(),
            );
          },
          loading: () => const CircularProgressIndicator(),
          error: (error, stack) => Text('Error: $error'),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
