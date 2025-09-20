import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../providers/providers_provider.dart';
import 'providers_screen.dart';
import '../../../core/models/provider.dart' as provider_model;

class ProviderDetailsScreen extends ConsumerWidget {
  final String providerId;

  const ProviderDetailsScreen({Key? key, required this.providerId})
    : super(key: key);

  String _formatDistance(
    Position? userLocation,
    provider_model.Provider provider,
  ) {
    if (userLocation == null || provider.location == null) return '';

    final distance = Geolocator.distanceBetween(
      userLocation.latitude,
      userLocation.longitude,
      provider.location!.latitude,
      provider.location!.longitude,
    );

    if (distance < 1000) {
      return '${distance.toStringAsFixed(0)}m away';
    } else {
      return '${(distance / 1000).toStringAsFixed(1)}km away';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userLocation = ref.watch(userLocationProvider);

    return Scaffold(
      body: FutureBuilder<provider_model.Provider?>(
        future: ref.read(providersProvider).getProviderById(providerId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading provider details: ${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            );
          }

          final provider = snapshot.data;
          if (provider == null) {
            return const Center(child: Text('Provider not found'));
          }

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(provider.businessName),
                  background: provider.profileImageUrl != null
                      ? Image.network(
                          provider.profileImageUrl!,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: Theme.of(context).primaryColor,
                          child: const Center(
                            child: Icon(
                              Icons.business,
                              size: 64,
                              color: Colors.white,
                            ),
                          ),
                        ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Rating and Distance
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star,
                                  size: 16,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  provider.rating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '(${provider.totalRatings} ratings)',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          if (userLocation != null &&
                              provider.location != null) ...[
                            const Spacer(),
                            const Icon(Icons.location_on, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              _formatDistance(userLocation, provider),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Contact Information
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Contact Information',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const Divider(),
                              ListTile(
                                leading: const Icon(Icons.phone),
                                title: Text(provider.phone),
                                onTap: () {
                                  // Implement phone call functionality
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.email),
                                title: Text(provider.email),
                                onTap: () {
                                  // Implement email functionality
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.location_on),
                                title: Text(provider.businessAddress),
                                onTap: () {
                                  // Implement navigation functionality
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Business Description
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'About',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const Divider(),
                              Text(provider.businessDescription),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Service Categories
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Services',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const Divider(),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: provider.serviceCategories.map((
                                  category,
                                ) {
                                  return Chip(
                                    label: Text(
                                      category.toString().split('.').last,
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onPrimary,
                                      ),
                                    ),
                                    backgroundColor: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Service Images
                      if (provider.serviceImages.isNotEmpty) ...[
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Gallery',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const Divider(),
                                SizedBox(
                                  height: 120,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: provider.serviceImages.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          right: 8,
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: Image.network(
                                            provider.serviceImages[index],
                                            width: 120,
                                            height: 120,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Implement booking functionality
        },
        icon: const Icon(Icons.calendar_today),
        label: const Text('Book Service'),
      ),
    );
  }
}
