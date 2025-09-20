import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:poafix/core/models/service.dart';
import 'package:poafix/core/services/service_service.dart';
import 'package:poafix/core/services/firebase_service.dart';

class ServiceListScreen extends StatelessWidget {
  const ServiceListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final serviceService = ServiceService();
    final currentUserId = FirebaseService().currentUserId;
    return Scaffold(
      appBar: AppBar(title: const Text('My Services')),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Services',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Expanded(
              child: StreamBuilder<List<Service>>(
                stream: serviceService.streamServices(
                  providerId: currentUserId,
                ),
                builder: (context, snapshot) {
                  if (currentUserId == null) {
                    return Center(
                      child: Text('Please log in to view your services'),
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  final services = snapshot.data ?? [];
                  if (services.isEmpty) {
                    return Center(
                      child: Text('No services found. Add your first service!'),
                    );
                  }
                  return ListView.separated(
                    itemCount: services.length,
                    separatorBuilder: (_, __) => SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final service = services[index];
                      return Builder(
                        builder: (rootContext) => _AnimatedServiceCard(
                          service: {
                            'title': service.name,
                            'price': 'KES ${service.price.toStringAsFixed(0)}',
                            'status': service.active == true
                                ? 'Active'
                                : 'Inactive',
                            'id': service.id,
                            'location': service.location != null
                                ? 'Lat: ${service.location!.latitude}, Lng: ${service.location!.longitude}'
                                : 'No location set',
                          },
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(24),
                                ),
                              ),
                              builder: (context) {
                                return Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.build,
                                            color: Colors.blue,
                                            size: 32,
                                          ),
                                          SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              service.name,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headlineSmall
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        'Price: KES ${service.price.toStringAsFixed(0)}',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleMedium,
                                      ),
                                      SizedBox(height: 8),
                                      _StatusBadge(
                                        status: service.active == true
                                            ? 'Active'
                                            : 'Inactive',
                                      ),
                                      SizedBox(height: 24),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: ElevatedButton.icon(
                                              icon: Icon(Icons.star),
                                              label: Text('Reviews'),
                                              style: ElevatedButton.styleFrom(
                                                minimumSize: Size(0, 40),
                                                backgroundColor: Colors.amber,
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                ),
                                              ),
                                              onPressed: () {
                                                Navigator.pop(context);
                                                GoRouter.of(rootContext).push(
                                                  '/service/${service.id}/reviews',
                                                );
                                              },
                                            ),
                                          ),
                                          SizedBox(width: 12),
                                          Expanded(
                                            child: ElevatedButton.icon(
                                              icon: Icon(Icons.edit),
                                              label: Text('Edit'),
                                              style: ElevatedButton.styleFrom(
                                                minimumSize: Size(0, 40),
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                ),
                                              ),
                                              onPressed: () {
                                                Navigator.pop(
                                                  context,
                                                ); // Close details modal
                                                if (rootContext.mounted) {
                                                  GoRouter.of(rootContext).push(
                                                    '/providerHome/service/edit/${service.id}',
                                                  );
                                                }
                                              },
                                            ),
                                          ),
                                          SizedBox(width: 12),
                                          Expanded(
                                            child: OutlinedButton.icon(
                                              icon: Icon(Icons.delete),
                                              label: Text('Delete'),
                                              style: OutlinedButton.styleFrom(
                                                minimumSize: Size(0, 40),
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                ),
                                              ),
                                              onPressed: () async {
                                                final confirm = await showDialog<bool>(
                                                  context: context,
                                                  builder: (context) => AlertDialog(
                                                    title: Text(
                                                      'Delete Service',
                                                    ),
                                                    content: Text(
                                                      'Are you sure you want to delete this service? This action cannot be undone.',
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                              context,
                                                              false,
                                                            ),
                                                        child: Text('Cancel'),
                                                      ),
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                              context,
                                                              true,
                                                            ),
                                                        child: Text(
                                                          'Delete',
                                                          style: TextStyle(
                                                            color: Colors.red,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                                if (confirm == true) {
                                                  await serviceService
                                                      .deleteService(
                                                        service.id,
                                                      );
                                                  Navigator.pop(
                                                    context,
                                                  ); // Close details modal
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        'Service deleted successfully',
                                                      ),
                                                    ),
                                                  );
                                                }
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => GoRouter.of(context).push('/providerHome/service/add'),
        child: Icon(Icons.add),
        tooltip: 'Add Service',
      ),
    );
  }
}

class _AnimatedServiceCard extends StatelessWidget {
  final Map<String, String> service; // Using map to maintain UI structure
  final VoidCallback onTap;
  const _AnimatedServiceCard({required this.service, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final status = service['status'] ?? '';
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
        ),
        child: ListTile(
          leading: Icon(Icons.build, color: Colors.blue),
          title: Text(
            service['title'] ?? '',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Price: ${service['price']}'),
              Text(
                service['location'] ?? 'No location set',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          trailing: _StatusBadge(status: status),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color = status == 'Active' ? Colors.green : Colors.red;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            status == 'Active' ? Icons.check_circle : Icons.cancel,
            color: color,
            size: 16,
          ),
          SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
