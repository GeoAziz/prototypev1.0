import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:poafix/core/models/category.dart';
import 'package:poafix/core/models/service.dart';
import 'package:poafix/core/theme/app_colors.dart';
import 'package:poafix/core/theme/app_text_styles.dart';
import 'package:poafix/core/widgets/app_text_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:poafix/features/home/widgets/popular_service_card.dart';
import 'package:poafix/features/service_category/widgets/sub_service_card.dart';
import 'package:poafix/core/services/firebase_service.dart';
import 'package:poafix/core/services/service_service.dart';
import 'package:poafix/core/utils/logger.dart';

final FirebaseService _firebaseService = FirebaseService();
final ServiceService _serviceService = ServiceService();
final _logger = Logger('ServiceCategoryScreen');

class ServiceCategoryScreen extends StatefulWidget {
  final String categoryId;
  final String? subService;

  const ServiceCategoryScreen({
    super.key,
    required this.categoryId,
    this.subService,
  });

  @override
  State<ServiceCategoryScreen> createState() => _ServiceCategoryScreenState();
}

class _ServiceCategoryScreenState extends State<ServiceCategoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedSubService = '';

  @override
  void initState() {
    super.initState();
    if (widget.subService != null) {
      _selectedSubService = widget.subService!;
      _logger.info(
        'Initializing with pre-selected sub-service: $_selectedSubService',
      );
    }
    _logger.debug(
      'Initializing category screen for categoryId: ${widget.categoryId}',
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: _firebaseService
          .collection('serviceCategories')
          .doc(widget.categoryId)
          .get(),
      builder: (context, catSnapshot) {
        if (catSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final catDoc = catSnapshot.data;
        if (catSnapshot.hasError || catDoc == null || !catDoc.exists) {
          return Scaffold(body: Center(child: Text('Category not found')));
        }
        final category = Category.fromJson(catDoc.data()!);

        return StreamBuilder<List<Service>>(
          stream: _serviceService.streamServices(categoryId: widget.categoryId),
          builder: (context, svcSnapshot) {
            if (svcSnapshot.connectionState == ConnectionState.waiting) {
              _logger.debug('Loading services for category ${category.id}...');
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            if (svcSnapshot.hasError) {
              _logger.error(
                'Error loading services for category ${category.id}',
                error: svcSnapshot.error,
                stackTrace: svcSnapshot.stackTrace,
              );
              return Scaffold(
                body: Center(child: Text('Error loading services')),
              );
            }
            var services = svcSnapshot.data ?? [];
            _logger.info(
              'Loaded ${services.length} services for category ${category.id}',
            );

            // Group services by subService
            final servicesBySubService = <String, List<Service>>{};
            for (final service in services) {
              final subService = service.subService ?? 'Other';
              if (!servicesBySubService.containsKey(subService)) {
                servicesBySubService[subService] = [];
              }
              servicesBySubService[subService]!.add(service);
            }

            return Scaffold(
              appBar: AppBar(
                title: Text(category.name),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(60),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: AppSearchField(
                      controller: _searchController,
                      hint: 'Search ${category.name} services...',
                      onChanged: (value) {
                        // Handle search
                      },
                    ),
                  ),
                ),
              ),
              body: Column(
                children: [
                  // Show selected sub-service title if any
                  if (_selectedSubService.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: AppColors.white,
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () {
                              setState(() {
                                _selectedSubService = '';
                                _logger.debug(
                                  'Navigated back to sub-services view',
                                );
                              });
                            },
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _selectedSubService,
                            style: AppTextStyles.subtitle1,
                          ),
                        ],
                      ),
                    ),

                  // Show either sub-services grid or service list
                  Expanded(
                    child: _selectedSubService.isEmpty
                        ? _buildSubServicesGrid(
                            category.subCategories ?? [],
                            servicesBySubService,
                            category,
                          )
                        : _buildServicesList(
                            servicesBySubService[_selectedSubService] ?? [],
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSubServicesGrid(
    List<String> subCategories,
    Map<String, List<Service>> servicesBySubService,
    Category category,
  ) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1,
      ),
      itemCount: subCategories.length,
      itemBuilder: (context, index) {
        final subService = subCategories[index];
        final serviceCount = servicesBySubService[subService]?.length ?? 0;

        return SubServiceCard(
          name: subService,
          serviceCount: serviceCount,
          onTap: () {
            // Navigate to dedicated sub-service screen
            context.push(
              '/categories/${widget.categoryId}/sub-services/$subService',
              extra: {
                'categoryName': category.name,
                'subServiceName': subService,
              },
            );
          },
        );
      },
    );
  }

  Widget _buildServicesList(List<Service> services) {
    if (services.isEmpty) {
      return const Center(child: Text('No services available'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        return PopularServiceCard(
          service: service,
          onTap: () {
            context.push('/service/${service.id}');
          },
        );
      },
    );
  }
}
