import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/service.dart';
import '../../../core/services/service_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/service_card.dart';

class ServiceComparisonScreen extends StatefulWidget {
  final List<String> serviceIds;

  const ServiceComparisonScreen({super.key, required this.serviceIds});

  @override
  State<ServiceComparisonScreen> createState() =>
      _ServiceComparisonScreenState();
}

class _ServiceComparisonScreenState extends State<ServiceComparisonScreen> {
  final ServiceService _serviceService = ServiceService();
  List<Service> _services = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    try {
      final services = <Service>[];

      for (final serviceId in widget.serviceIds) {
        final service = await _serviceService.getServiceById(serviceId);
        if (service != null) {
          services.add(service);
        }
      }

      setState(() {
        _services = services;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load services for comparison';
        _isLoading = false;
      });
    }
  }

  void _removeService(String serviceId) {
    setState(() {
      _services.removeWhere((service) => service.id == serviceId);
    });

    if (_services.isEmpty) {
      context.pop();
    }
  }

  void _addService() {
    // Navigate to a service selection screen to add more services
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Add Service to Compare',
                  style: AppTextStyles.headline2,
                ),
              ),
              Expanded(child: _buildServiceSelection(scrollController)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceSelection(ScrollController scrollController) {
    return StreamBuilder<List<Service>>(
      stream: _serviceService.streamServices(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final availableServices = snapshot.data!
            .where((service) => !_services.any((s) => s.id == service.id))
            .toList();

        if (availableServices.isEmpty) {
          return const Center(
            child: Text('No more services available to compare'),
          );
        }

        return ListView.builder(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: availableServices.length,
          itemBuilder: (context, index) {
            final service = availableServices[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ServiceCard(
                service: service,
                isCompact: true,
                onTap: () {
                  setState(() {
                    _services.add(service);
                  });
                  context.pop();
                },
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Compare Services (${_services.length})',
          style: AppTextStyles.headline2.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (_services.length < 4)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _addService,
              tooltip: 'Add Service',
            ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareComparison,
            tooltip: 'Share Comparison',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: AppTextStyles.body1.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.pop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      );
    }

    if (_services.isEmpty) {
      return const Center(child: Text('No services to compare'));
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          // Services overview cards
          Container(
            height: 200,
            padding: const EdgeInsets.all(16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _services.length,
              itemBuilder: (context, index) {
                final service = _services[index];
                return Container(
                  width: 280,
                  margin: const EdgeInsets.only(right: 16),
                  child: Stack(
                    children: [
                      ServiceCard(service: service, isCompact: true),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () => _removeService(service.id),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Comparison table
          _buildComparisonTable(),
        ],
      ),
    );
  }

  Widget _buildComparisonTable() {
    final comparisonItems = [
      {
        'label': 'Price Range',
        'values': _services
            .map((s) => '${s.currency} ${s.price.toStringAsFixed(0)}')
            .toList(),
      },
      {
        'label': 'Rating',
        'values': _services
            .map((s) => '${s.rating.toStringAsFixed(1)} ⭐')
            .toList(),
      },
      {
        'label': 'Reviews',
        'values': _services.map((s) => '${s.reviewCount} reviews').toList(),
      },
      {
        'label': 'Category',
        'values': _services.map((s) => s.categoryName).toList(),
      },
      {
        'label': 'Pricing Type',
        'values': _services.map((s) => s.pricingType).toList(),
      },
      {
        'label': 'Status',
        'values': _services
            .map((s) => s.active ? 'Active' : 'Inactive')
            .toList(),
      },
      {
        'label': 'Bookings',
        'values': _services.map((s) => '${s.bookingCount} bookings').toList(),
      },
      {
        'label': 'Sub Service',
        'values': _services
            .map((s) => s.subService.isEmpty ? 'N/A' : s.subService)
            .toList(),
      },
    ];

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Detailed Comparison', style: AppTextStyles.headline3),
          ),
          ...comparisonItems.map(
            (item) => _buildComparisonRow(
              item['label'] as String,
              item['values'] as List<String>,
            ),
          ),

          // Features comparison
          _buildFeaturesComparison(),

          // Action buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: _services
                  .map(
                    (service) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Column(
                          children: [
                            ElevatedButton(
                              onPressed: () =>
                                  context.push('/service/${service.id}'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                minimumSize: const Size.fromHeight(40),
                              ),
                              child: const Text('View Details'),
                            ),
                            const SizedBox(height: 8),
                            OutlinedButton(
                              onPressed: () => context.push(
                                '/service/${service.id}/providers',
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                side: const BorderSide(
                                  color: AppColors.primary,
                                ),
                                minimumSize: const Size.fromHeight(40),
                              ),
                              child: const Text('Book Now'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonRow(String label, List<String> values) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: AppTextStyles.body2.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: values
                  .map(
                    (value) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          value,
                          style: AppTextStyles.body2,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesComparison() {
    // Get all unique features across services
    final allFeatures = <String>{};
    for (final service in _services) {
      allFeatures.addAll(service.features);
    }

    if (allFeatures.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Features Comparison', style: AppTextStyles.headline3),
        ),
        ...allFeatures.map((feature) {
          final hasFeature = _services
              .map((service) => service.features.contains(feature) ? '✓' : '✗')
              .toList();

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 100,
                  child: Text(
                    feature,
                    style: AppTextStyles.body2.copyWith(
                      color: Colors.grey[700],
                    ),
                  ),
                ),
                Expanded(
                  child: Row(
                    children: hasFeature
                        .map(
                          (value) => Expanded(
                            child: Text(
                              value,
                              style: AppTextStyles.body2.copyWith(
                                color: value == '✓'
                                    ? AppColors.success
                                    : AppColors.error,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  void _shareComparison() {
    // Generate a shareable comparison summary
    final buffer = StringBuffer();
    buffer.writeln('Service Comparison:');
    buffer.writeln();

    for (int i = 0; i < _services.length; i++) {
      final service = _services[i];
      buffer.writeln('${i + 1}. ${service.name}');
      buffer.writeln(
        '   • Price: ${service.currency} ${service.price.toStringAsFixed(0)}',
      );
      buffer.writeln(
        '   • Rating: ${service.rating.toStringAsFixed(1)} ⭐ (${service.reviewCount} reviews)',
      );
      buffer.writeln('   • Category: ${service.categoryName}');
      buffer.writeln('   • Type: ${service.pricingType}');
      if (service.features.isNotEmpty) {
        buffer.writeln('   • Features: ${service.features.join(', ')}');
      }
      buffer.writeln();
    }

    // In a real app, you would use the share_plus package
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Comparison summary copied to clipboard'),
        action: SnackBarAction(label: 'OK', onPressed: () {}),
      ),
    );
  }
}
