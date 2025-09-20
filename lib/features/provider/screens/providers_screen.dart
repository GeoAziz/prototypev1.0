import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/enums/service_category.dart';
import '../providers/providers_provider.dart';
import '../widgets/provider_filters.dart';
import '../widgets/providers_list.dart';
import '../../../core/models/provider.dart' as provider_model;

final userLocationProvider = StateProvider<Position?>((ref) => null);
final selectedCategoryProvider = StateProvider<ServiceCategory?>((ref) => null);
final searchRadiusProvider = StateProvider<double>((ref) => 10.0);
final searchQueryProvider = StateProvider<String>((ref) => '');

class ProvidersScreen extends ConsumerStatefulWidget {
  const ProvidersScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ProvidersScreen> createState() => _ProvidersScreenState();
}

class _ProvidersScreenState extends ConsumerState<ProvidersScreen> {
  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      ref.read(userLocationProvider.notifier).state = position;
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userLocation = ref.watch(userLocationProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final searchRadius = ref.watch(searchRadiusProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    if (userLocation == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Getting your location...',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      );
    }

    final nearbyProvidersStream = ref.watch(
      nearbyProvidersStreamProvider(
        NearbyProvidersParams(
          center: GeoPoint(userLocation.latitude, userLocation.longitude),
          radius: searchRadius,
          category: selectedCategory,
          searchQuery: searchQuery.isEmpty ? null : searchQuery,
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Providers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _getCurrentLocation,
          ),
        ],
      ),
      body: Column(
        children: [
          ProviderFilters(
            selectedCategory: selectedCategory,
            selectedRadius: searchRadius,
            searchQuery: searchQuery,
            onCategoryChanged: (category) {
              ref.read(selectedCategoryProvider.notifier).state = category;
            },
            onRadiusChanged: (radius) {
              ref.read(searchRadiusProvider.notifier).state = radius;
            },
            onSearchChanged: (query) {
              ref.read(searchQueryProvider.notifier).state = query;
            },
          ),
          const Divider(),
          Expanded(
            child: nearbyProvidersStream.when(
              data: (providers) {
                return ProvidersList(
                  providers: providers,
                  userLocation: userLocation,
                  onProviderTap: (provider) {
                    // Navigate to provider details
                    // You can implement this based on your navigation setup
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading providers: $error',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
