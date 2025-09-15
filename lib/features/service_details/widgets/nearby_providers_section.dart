import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/models/provider.dart';
import '../../../core/services/location_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../screens/provider_details_screen.dart';

class NearbyProvidersSection extends StatefulWidget {
  final String serviceId;
  final double radius;

  const NearbyProvidersSection({
    super.key,
    required this.serviceId,
    this.radius = 10.0, // Default 10km radius
  });

  @override
  State<NearbyProvidersSection> createState() => _NearbyProvidersSectionState();
}

class _NearbyProvidersSectionState extends State<NearbyProvidersSection> {
  final LocationService _locationService = LocationService();
  GeoPoint? _userLocation;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    try {
      final position = await _locationService.getCurrentLocation();
      setState(() {
        _userLocation = GeoPoint(position.latitude, position.longitude);
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _errorMessage =
            'Could not access location. Please enable location services.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(_errorMessage!, style: TextStyle(color: Colors.red)),
      );
    }

    if (_userLocation == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return StreamBuilder<List<ServiceProvider>>(
      stream: _locationService.getNearbyProviders(
        _userLocation!.latitude,
        _userLocation!.longitude,
        widget.radius,
      ),
      builder: (context, snapshot) {
        debugPrint(
          '[NearbyProvidersSection] User location: ${_userLocation!.latitude}, ${_userLocation!.longitude}',
        );
        if (snapshot.hasError) {
          debugPrint(
            '[NearbyProvidersSection] Provider query error: ${snapshot.error}',
          );
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Error: ${snapshot.error}'),
          );
        }

        if (!snapshot.hasData) {
          debugPrint('[NearbyProvidersSection] Provider query loading...');
          return const Center(child: CircularProgressIndicator());
        }

        final providers = snapshot.data!;
        debugPrint(
          '[NearbyProvidersSection] Providers found: ${providers.length}',
        );
        for (final p in providers) {
          debugPrint(
            '[NearbyProvidersSection] Provider: id=${p.id}, name=${p.name}, location=${p.location.latitude},${p.location.longitude}, isActive=${p.isActive}',
          );
        }
        if (providers.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('No providers found in your area'),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: providers.length,
          itemBuilder: (context, index) {
            final provider = providers[index];
            final distance = _locationService.calculateDistance(
              _userLocation!,
              provider.location,
            );

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          ProviderDetailsScreen(providerId: provider.id),
                    ),
                  );
                },
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(provider.photo),
                    radius: 25,
                  ),
                  title: Text(provider.name, style: AppTextStyles.headline3),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(provider.bio, style: AppTextStyles.body2),
                      const SizedBox(height: 4),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            Icon(Icons.star, size: 16, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              '${provider.rating} (${provider.reviewCount} reviews)',
                              style: AppTextStyles.body2,
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.location_on,
                              size: 16,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${(distance / 1000).toStringAsFixed(1)} km away',
                              style: AppTextStyles.body2,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // ...no trailing button, card itself is clickable...
                ),
              ),
            );
          },
        );
      },
    );
  }
}
