import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/models/provider.dart' as provider_model;
import 'provider_card.dart';

class ProvidersList extends ConsumerWidget {
  final List<provider_model.Provider> providers;
  final Position? userLocation;
  final Function(provider_model.Provider)? onProviderTap;
  final bool showDistance;
  final bool isLoading;
  final String? error;
  final ScrollController? scrollController;

  const ProvidersList({
    Key? key,
    required this.providers,
    this.userLocation,
    this.onProviderTap,
    this.showDistance = true,
    this.isLoading = false,
    this.error,
    this.scrollController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              error!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      );
    }

    if (providers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No providers found',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: providers.length,
      itemBuilder: (context, index) {
        final provider = providers[index];
        return ProviderCard(
          provider: provider,
          userLocation: userLocation,
          showDistance: showDistance,
          onTap: onProviderTap != null ? () => onProviderTap!(provider) : null,
        );
      },
    );
  }
}
