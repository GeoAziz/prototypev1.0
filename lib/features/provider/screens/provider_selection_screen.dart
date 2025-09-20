import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/models/service.dart';
import '../../../core/models/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/loading_overlay.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/utils/location_utils.dart';

class ProviderSelectionScreen extends StatefulWidget {
  final String serviceId;

  const ProviderSelectionScreen({super.key, required this.serviceId});

  @override
  State<ProviderSelectionScreen> createState() =>
      _ProviderSelectionScreenState();
}

class _ProviderSelectionScreenState extends State<ProviderSelectionScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  Service? _service;
  List<Provider> _providers = [];
  bool _isLoading = true;
  String _sortBy = 'rating'; // rating, distance, price
  Position? _userLocation;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // Load service details
      await _loadService();

      // Get user location for distance calculation
      await _getUserLocation();

      // Load providers for this service
      await _loadProviders();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadService() async {
    try {
      final doc = await _firebaseService
          .collection('services')
          .doc(widget.serviceId)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        _service = Service.fromJson(data);
      }
    } catch (e) {
      debugPrint('Error loading service: $e');
    }
  }

  Future<void> _getUserLocation() async {
    try {
      _userLocation = await LocationUtils.getCurrentLocation();
    } catch (e) {
      debugPrint('Error getting user location: $e');
    }
  }

  Future<void> _loadProviders() async {
    if (_service == null) return;

    try {
      // Find providers who offer this service
      final serviceProvidersQuery = await _firebaseService
          .collection('services')
          .where('name', isEqualTo: _service!.name)
          .where('categoryId', isEqualTo: _service!.categoryId)
          .get();

      final providerIds = serviceProvidersQuery.docs
          .map((doc) => doc.data()['providerId'] as String?)
          .where((id) => id != null && id.isNotEmpty)
          .toSet()
          .toList();

      if (providerIds.isEmpty) {
        setState(() => _providers = []);
        return;
      }

      // Load provider details
      final providersQuery = await _firebaseService
          .collection('providers')
          .where(FieldPath.documentId, whereIn: providerIds)
          .get();

      final providers = <Provider>[];
      for (final doc in providersQuery.docs) {
        try {
          final data = doc.data();
          data['id'] = doc.id;

          // Calculate distance if user location available
          if (_userLocation != null && data['location'] != null) {
            final providerLocation = data['location'] as GeoPoint;
            final distance =
                Geolocator.distanceBetween(
                  _userLocation!.latitude,
                  _userLocation!.longitude,
                  providerLocation.latitude,
                  providerLocation.longitude,
                ) /
                1000; // Convert to kilometers
            data['distance'] = distance;
          }

          providers.add(Provider.fromJson(data));
        } catch (e) {
          debugPrint('Error parsing provider ${doc.id}: $e');
        }
      }

      _sortProviders(providers);
      setState(() => _providers = providers);
    } catch (e) {
      debugPrint('Error loading providers: $e');
    }
  }

  void _sortProviders(List<Provider> providers) {
    switch (_sortBy) {
      case 'rating':
        providers.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'distance':
        providers.sort((a, b) {
          final aDistance = a.distance ?? double.infinity;
          final bDistance = b.distance ?? double.infinity;
          return aDistance.compareTo(bDistance);
        });
        break;
      case 'price':
        providers.sort((a, b) => a.averagePrice.compareTo(b.averagePrice));
        break;
    }
  }

  void _onSortChanged(String sortBy) {
    setState(() {
      _sortBy = sortBy;
      _sortProviders(_providers);
    });
  }

  void _selectProvider(Provider provider) {
    context.push(
      '/booking?serviceId=${widget.serviceId}&providerId=${provider.id}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Provider'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: _onSortChanged,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'rating',
                child: Text('Sort by Rating'),
              ),
              const PopupMenuItem(
                value: 'distance',
                child: Text('Sort by Distance'),
              ),
              const PopupMenuItem(value: 'price', child: Text('Sort by Price')),
            ],
          ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: Column(
          children: [
            // Service Info Header
            if (_service != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withOpacity(0.1),
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade300, width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        _service!.image,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.image_not_supported),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_service!.name, style: AppTextStyles.headline3),
                          const SizedBox(height: 4),
                          Text(
                            'KES ${_service!.price.toStringAsFixed(0)}',
                            style: AppTextStyles.body1.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Providers List
            Expanded(
              child: _providers.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_search,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No providers available for this service',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _providers.length,
                      itemBuilder: (context, index) {
                        final provider = _providers[index];
                        return _buildProviderCard(provider);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderCard(Provider provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _selectProvider(provider),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Provider Avatar
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: provider.profileImage.isNotEmpty
                        ? NetworkImage(provider.profileImage)
                        : null,
                    backgroundColor: AppColors.primaryLight,
                    child: provider.profileImage.isEmpty
                        ? Text(
                            provider.businessName.isNotEmpty
                                ? provider.businessName[0].toUpperCase()
                                : 'P',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),

                  // Provider Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          provider.businessName,
                          style: AppTextStyles.subtitle1,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.amber[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${provider.rating.toStringAsFixed(1)} (${provider.reviewCount} reviews)',
                              style: AppTextStyles.caption,
                            ),
                          ],
                        ),
                        if (provider.distance != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 16,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${provider.distance!.toStringAsFixed(1)} km away',
                                style: AppTextStyles.caption,
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Price and Status
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'From KES ${provider.averagePrice.toStringAsFixed(0)}',
                        style: AppTextStyles.body1.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: provider.isAvailable
                              ? Colors.green.shade100
                              : Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          provider.isAvailable ? 'Available' : 'Busy',
                          style: TextStyle(
                            fontSize: 12,
                            color: provider.isAvailable
                                ? Colors.green.shade700
                                : Colors.orange.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Service Areas
              if (provider.serviceAreas.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  'Service Areas:',
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: provider.serviceAreas.take(3).map((area) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.primaryLight.withOpacity(0.3),
                        ),
                      ),
                      child: Text(area, style: AppTextStyles.caption),
                    );
                  }).toList(),
                ),
              ],

              // Quick Actions
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Show provider profile
                      },
                      icon: const Icon(Icons.person, size: 16),
                      label: const Text('View Profile'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _selectProvider(provider),
                      icon: const Icon(Icons.book_online, size: 16),
                      label: const Text('Book Now'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
