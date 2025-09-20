import 'package:flutter/material.dart';
import '../../../core/models/service.dart';
import '../../../core/services/service_service.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../widgets/service_card.dart';

class ServiceManagementScreen extends StatefulWidget {
  const ServiceManagementScreen({super.key});

  @override
  State<ServiceManagementScreen> createState() =>
      _ServiceManagementScreenState();
}

class _ServiceManagementScreenState extends State<ServiceManagementScreen> {
  final _serviceService = ServiceService();
  // TODO: Replace with actual provider ID from auth
  final String currentProviderId = 'demo_provider_id';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddServiceDialog(),
          ),
        ],
      ),
      body: StreamBuilder<List<Service>>(
        stream: _serviceService.streamServices(providerId: currentProviderId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState();
          }

          if (snapshot.hasError) {
            return ErrorView(
              error: 'Error loading services: ${snapshot.error}',
              onRetry: () => setState(() {}),
            );
          }

          final services = snapshot.data ?? [];
          if (services.isEmpty) {
            return const EmptyState(
              message: 'No services added yet.\nAdd your first service!',
              icon: Icons.business,
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];
              return ServiceCard(
                title: service.name,
                price: service.price,
                priceMax: service.priceMax,
                currency: service.currency,
                pricingType: service.pricingType,
                status: service.isFeatured ? 'active' : 'inactive',
                onTap: () => _showEditServiceDialog(service),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (context, index) =>
          SizedBox(height: 80), // Placeholder shimmer
    );
  }

  Future<void> _showAddServiceDialog() async {
    // TODO: Replace with actual service form dialog
    // For now, just add a demo service
    final demoService = Service(
      id: '',
      name: 'Demo Service',
      description: 'Demo description',
      price: 100,
      categoryId: 'demo',
      image: '',
      rating: 0,
      reviewCount: 0,
      bookingCount: 0,
      images: [],
      features: [],
      providerId: currentProviderId,
    );
    try {
      await _serviceService.addService(demoService);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Service added successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error adding service: $e')));
      }
    }
  }

  Future<void> _showEditServiceDialog(Service service) async {
    // TODO: Replace with actual service edit dialog
    // For now, just update the name
    try {
      await _serviceService.updateService(service.id, {
        'name': service.name + ' (edited)',
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Service updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating service: $e')));
      }
    }
  }

  Future<void> _deleteService(String serviceId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Service'),
        content: const Text('Are you sure you want to delete this service?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _serviceService.deleteService(serviceId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Service deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error deleting service: $e')));
        }
      }
    }
  }

  Future<void> _toggleServiceAvailability(
    String serviceId,
    bool isAvailable,
  ) async {
    try {
      await _serviceService.updateService(serviceId, {
        'isFeatured': isAvailable,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Service ${isAvailable ? 'enabled' : 'disabled'} successfully',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating service: $e')));
      }
    }
  }
}
