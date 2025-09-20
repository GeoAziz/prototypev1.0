import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/models/service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/loading_overlay.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/widgets/service_card.dart';
import '../../../core/utils/logger.dart';

class SubServiceListScreen extends StatefulWidget {
  final String categoryId;
  final String subServiceId;
  final String categoryName;
  final String subServiceName;

  const SubServiceListScreen({
    super.key,
    required this.categoryId,
    required this.subServiceId,
    required this.categoryName,
    required this.subServiceName,
  });

  @override
  State<SubServiceListScreen> createState() => _SubServiceListScreenState();
}

class _SubServiceListScreenState extends State<SubServiceListScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  List<Service> _services = [];
  bool _isLoading = true;
  String _sortBy = 'rating'; // rating, price_low, price_high, popularity
  String _searchQuery = '';
  final _logger = Logger('SubServiceListScreen');
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _logger.info('Initializing SubServiceListScreen');
    _logger.info(
      'Parameters: categoryId=${widget.categoryId}, subServiceId=${widget.subServiceId}',
    );
    _loadServices();
  }

  Future<void> _loadServices() async {
    _logger.debug(
      'Loading services for categoryId: ${widget.categoryId}, subService: ${widget.subServiceId}',
    );
    setState(() => _isLoading = true);

    try {
      _logger.debug(
        'Building query with sort: $_sortBy, search: "${_searchQuery.isEmpty ? 'none' : _searchQuery}"',
      );

      Query<Map<String, dynamic>> query = _firebaseService
          .collection('services')
          .where('categoryId', isEqualTo: widget.categoryId)
          .where('subService', isEqualTo: widget.subServiceId);

      _logger.debug('Base query created with filters');

      // Apply search filter if provided
      if (_searchQuery.isNotEmpty) {
        _logger.debug('Adding search filter for: $_searchQuery');
        query = query.where(
          'searchKeywords',
          arrayContains: _searchQuery.toLowerCase(),
        );
      }

      // Apply sorting
      _logger.debug('Applying sort: $_sortBy');
      switch (_sortBy) {
        case 'price_low':
          query = query.orderBy('price', descending: false);
          break;
        case 'price_high':
          query = query.orderBy('price', descending: true);
          break;
        case 'rating':
          query = query.orderBy('rating', descending: true);
          break;
        case 'popularity':
          query = query.orderBy('bookingCount', descending: true);
          break;
        default:
          query = query.orderBy('createdAt', descending: true);
      }

      _logger.debug('Executing Firestore query...');
      final snapshot = await query.get();
      _logger.info('Retrieved ${snapshot.docs.length} services from Firestore');
      final services = <Service>[];

      for (final doc in snapshot.docs) {
        try {
          _logger.debug('Processing service document: ${doc.id}');
          final data = doc.data();
          _logger.debug('Service data: ${data.toString()}');

          // Handle missing or invalid fields with defaults
          if (!data.containsKey('image') || data['image'] == null) {
            _logger.warning(
              'Using default image for service ${doc.id}: Missing image field',
            );
            data['image'] = Service.defaultImage;
          }

          if (!data.containsKey('features') || data['features'] == null) {
            _logger.warning('Using empty features list for service ${doc.id}');
            data['features'] = [];
          }

          // Ensure features is a list
          if (data['features'] is! List) {
            _logger.warning(
              'Converting features to list for service ${doc.id}',
            );
            data['features'] = [data['features'].toString()];
          }

          data['id'] = doc.id;
          final service = Service.fromJson(data);
          _logger.debug('Successfully parsed service: ${service.name}');
          services.add(service);
        } catch (e, stack) {
          _logger.error(
            'Error parsing service ${doc.id}: $e',
            error: e,
            stackTrace: stack,
          );
          continue;
        }
      }

      _logger.info('Successfully loaded ${services.length} services');
      if (mounted) {
        setState(() {
          _services = services;
          _isLoading = false;
        });
      }
    } catch (e, stack) {
      _logger.error('Error loading services', error: e, stackTrace: stack);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading services: $e')));
        setState(() => _isLoading = false);
      }
    }
  }

  void _onSortChanged(String sortBy) {
    _logger.debug('Sort changed from $_sortBy to $sortBy');
    setState(() {
      _sortBy = sortBy;
    });
    _loadServices();
  }

  void _onSearchChanged(String query) {
    _logger.debug('Search query changed: "$query"');
    setState(() {
      _searchQuery = query;
    });
    _loadServices();
  }

  String _getSortDisplayName(String sortBy) {
    switch (sortBy) {
      case 'rating':
        return 'Rating';
      case 'price_low':
        return 'Price (Low)';
      case 'price_high':
        return 'Price (High)';
      case 'popularity':
        return 'Popularity';
      default:
        return 'Default';
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty
                ? 'No services found for "$_searchQuery"'
                : 'No ${widget.subServiceName.toLowerCase()} services available',
            style: AppTextStyles.body1.copyWith(color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'Try searching with different keywords'
                : 'Check back later for new services',
            style: AppTextStyles.caption,
            textAlign: TextAlign.center,
          ),
          if (_searchQuery.isNotEmpty) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                });
                _loadServices();
              },
              child: const Text('Clear Search'),
            ),
          ],
        ],
      ),
    );
  }

  void _navigateToService(Service service) {
    _logger.info('Navigating to service: ${service.id} (${service.name})');
    context.push('/service/${service.id}');
  }

  @override
  Widget build(BuildContext context) {
    _logger.debug('Building SubServiceListScreen');
    _logger.debug(
      'Current state: services=${_services.length}, loading=$_isLoading, sortBy=$_sortBy',
    );

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.subServiceName, style: const TextStyle(fontSize: 18)),
            Text(
              widget.categoryName,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: Colors.grey,
              ),
            ),
          ],
        ),
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
                value: 'price_low',
                child: Text('Price: Low to High'),
              ),
              const PopupMenuItem(
                value: 'price_high',
                child: Text('Price: High to Low'),
              ),
              const PopupMenuItem(
                value: 'popularity',
                child: Text('Most Popular'),
              ),
            ],
          ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isLoading) const LinearProgressIndicator(),
                  // Debug Info Banner (only in debug mode)
                  if (kDebugMode)
                    Container(
                      padding: const EdgeInsets.all(8),
                      color: Colors.yellow.withOpacity(0.1),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '🔍 Debug Info:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text('Category ID: ${widget.categoryId}'),
                          Text('SubService ID: ${widget.subServiceId}'),
                          Text('Services loaded: ${_services.length}'),
                          Text('Sort by: $_sortBy'),
                          Text('Loading: $_isLoading'),
                        ],
                      ),
                    ),
                  // Search Bar
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText:
                            'Search ${widget.subServiceName.toLowerCase()} services...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onChanged: _onSearchChanged,
                    ),
                  ),
                  // Services Count and Filters
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Text(
                          '${_services.length} ${_services.length == 1 ? 'service' : 'services'} found',
                          style: AppTextStyles.body2.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Sorted by: ${_getSortDisplayName(_sortBy)}',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Services List
                  Expanded(
                    child: _services.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _services.length,
                            itemBuilder: (context, index) {
                              _logger.debug(
                                'Building service card at index $index',
                              );
                              final service = _services[index];
                              _logger.debug(
                                'Service details: id=${service.id}, name=${service.name}, price=${service.price}',
                              );
                              return Container(
                                height: 160, // Fixed height for each card
                                margin: const EdgeInsets.only(bottom: 12),
                                child: ServiceCard(
                                  key: ValueKey(service.id),
                                  service: service,
                                  onTap: () => _navigateToService(service),
                                  showProvider: true,
                                  isCompact: true,
                                ),
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButton: _services.length > 1
          ? FloatingActionButton.extended(
              onPressed: () {
                // TODO: Implement service comparison
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Service comparison coming soon!'),
                  ),
                );
              },
              icon: const Icon(Icons.compare_arrows),
              label: const Text('Compare'),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            )
          : null,
    );
  }
}
