import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/availability_model.dart';
import '../providers/availability_provider.dart';
// Ensure the following import brings in availabilityStateProvider
// If availabilityStateProvider is not exported, update the providers file to export it.

class AvailabilityWidget extends ConsumerWidget {
  final String providerId;
  const AvailabilityWidget({super.key, required this.providerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(availabilityProvider(providerId));
    if (state.isLoading) {
      return const CircularProgressIndicator();
    }
    if (state.availability == null) {
      return const Text('No availability data');
    }
    final availability = state.availability!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              availability.isOnline ? Icons.circle : Icons.circle_outlined,
              color: availability.isOnline ? Colors.green : Colors.grey,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(availability.isOnline ? 'Online' : 'Offline'),
          ],
        ),
        const SizedBox(height: 8),
        Text('Available Slots:'),
        ...availability.availableSlots.map(
          (dt) => Text(dt.toLocal().toString()),
        ),
      ],
    );
  }
}
