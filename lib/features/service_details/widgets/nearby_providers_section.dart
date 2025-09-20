import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/provider.dart';
import '../../../core/models/location.dart';
import '../../../core/services/location_service.dart';
import '../../../core/enums/service_category.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../screens/provider_details_screen.dart';

class NearbyProvidersSection extends StatefulWidget {
  final String serviceId;
  final String serviceCategoryName;
  final double radius;

  const NearbyProvidersSection({
    super.key,
    required this.serviceId,
    required this.serviceCategoryName,
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

    // Map serviceCategoryName to ServiceCategory enum
    ServiceCategory? category;
    try {
      category = ServiceCategory.values.firstWhere(
        (cat) =>
            cat.displayName.toLowerCase() ==
            widget.serviceCategoryName.toLowerCase(),
        orElse: () => ServiceCategory.other,
      );
    } catch (_) {
      category = ServiceCategory.other;
    }
    return StreamBuilder<List<Provider>>(
      stream: _locationService.getNearbyProviders(
        _userLocation!.latitude,
        _userLocation!.longitude,
        widget.radius,
        category,
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
          if (p.location != null) {
            debugPrint(
              '[NearbyProvidersSection] Provider: id=${p.id}, name=${p.name}, location=${p.location!.latitude},${p.location!.longitude}, isActive=${p.isActive}',
            );
          }
        }
        if (providers.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('No providers found in your area'),
          );
        }

        // Show header with "View All Providers" button
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header with action button
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Available Providers (${providers.length})',
                    style: AppTextStyles.headline3,
                  ),
                  TextButton.icon(
                    onPressed: () {
                      context.push('/service/${widget.serviceId}/providers');
                    },
                    icon: const Icon(Icons.view_list, size: 18),
                    label: const Text('View All'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),

            // Show first 3 providers as preview
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: providers.length > 3 ? 3 : providers.length,
              itemBuilder: (context, index) {
                final provider = providers[index];
                final distance = provider.location != null
                    ? _locationService.calculateDistance(
                        Location(
                          latitude: _userLocation!.latitude,
                          longitude: _userLocation!.longitude,
                        ),
                        Location(
                          latitude: provider.location!.latitude,
                          longitude: provider.location!.longitude,
                        ),
                      )
                    : 0.0;

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
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
                        backgroundImage: provider.profileImageUrl != null
                            ? NetworkImage(provider.profileImageUrl!)
                            : null,
                        radius: 25,
                        child: provider.profileImageUrl == null
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      title: Text(
                        provider.name,
                        style: AppTextStyles.headline3,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            provider.businessDescription,
                            style: AppTextStyles.body2,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                size: 16,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${provider.rating} (${provider.totalRatings})',
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
                                '${(distance / 1000).toStringAsFixed(1)} km',
                                style: AppTextStyles.body2,
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    ),
                  ),
                );
              },
            ),

            // Show "View All" message if there are more providers
            if (providers.length > 3)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: TextButton(
                    onPressed: () {
                      context.push('/service/${widget.serviceId}/providers');
                    },
                    child: Text(
                      'View ${providers.length - 3} more providers →',
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
