import 'package:flutter/material.dart';
import '../../../core/models/provider.dart';
import 'package:geolocator/geolocator.dart';

class ProviderCard extends StatelessWidget {
  final Provider provider;
  final Position? userLocation;
  final VoidCallback? onTap;
  final bool showDistance;

  const ProviderCard({
    Key? key,
    required this.provider,
    this.userLocation,
    this.onTap,
    this.showDistance = true,
  }) : super(key: key);

  String _getDistance() {
    if (userLocation == null || provider.location == null) return '';

    final distance = Geolocator.distanceBetween(
      userLocation!.latitude,
      userLocation!.longitude,
      provider.location!.latitude,
      provider.location!.longitude,
    );

    if (distance < 1000) {
      return '${distance.toStringAsFixed(0)}m';
    } else {
      return '${(distance / 1000).toStringAsFixed(1)}km';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: provider.profileImageUrl != null
                        ? NetworkImage(provider.profileImageUrl!)
                        : null,
                    child: provider.profileImageUrl == null
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          provider.businessName,
                          style: Theme.of(context).textTheme.titleLarge,
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
                              provider.rating.toStringAsFixed(1),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(${provider.totalRatings})',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            if (showDistance &&
                                userLocation != null &&
                                provider.location != null) ...[
                              const Spacer(),
                              Icon(
                                Icons.location_on,
                                size: 16,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _getDistance(),
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                provider.businessDescription,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: provider.serviceCategories.map((category) {
                  return Chip(
                    label: Text(
                      category.toString().split('.').last,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
