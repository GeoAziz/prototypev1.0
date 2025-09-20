// Removed unused import for ServiceService
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:poafix/core/models/category.dart';
import 'package:poafix/core/models/service.dart';
import 'package:poafix/core/models/promotion.dart';
import 'package:poafix/core/services/category_service.dart';
import 'package:poafix/core/services/service_service.dart';
import 'package:poafix/core/services/promotion_service.dart';
import 'package:poafix/core/theme/app_colors.dart';
import 'package:poafix/core/theme/app_text_styles.dart';
import 'package:poafix/core/widgets/app_text_field.dart';
import 'package:poafix/core/widgets/category_card.dart';
import 'package:poafix/core/widgets/featured_service_card.dart';
import 'package:poafix/core/widgets/popular_service_card.dart';
import 'package:poafix/core/widgets/promo_card.dart';
import 'package:poafix/core/widgets/section_header.dart';

// ...imports...

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final _categoryService = CategoryService();
  // Removed unused _serviceService
  final _promotionService = PromotionService();

  late Stream<List<Category>> _categoriesStream;
  final List<Service> _featuredServices = [];
  bool _isLoadingFeatured = false;
  bool _hasMoreFeatured = true;
  DocumentSnapshot? _lastFeaturedDoc;
  late Stream<List<Service>> _popularServicesStream;
  late Stream<List<Promotion>> _promotionsStream;

  @override
  void initState() {
    super.initState();
    _initStreams();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _initStreams() {
    _categoriesStream = _categoryService.streamCategories();
    _popularServicesStream = FirebaseFirestore.instance
        .collection('popular_services')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            var data = Map<String, dynamic>.from(doc.data());
            data['id'] = doc.id;
            return Service.fromJson(data);
          }).toList(),
        );
    _promotionsStream = _promotionService.streamPromotions();
    _loadFeaturedServices();
  }

  void _handleSearch(String query) {
    if (query.trim().isNotEmpty) {
      context.push('/search?query=${Uri.encodeComponent(query)}');
    }
  }

  Future<void> _loadFeaturedServices() async {
    if (!mounted || _isLoadingFeatured || !_hasMoreFeatured) return;

    setState(() {
      _isLoadingFeatured = true;
    });

    try {
      final query = FirebaseFirestore.instance
          .collection('featured_services')
          .orderBy('bookingCount', descending: true)
          .limit(10);

      debugPrint('[FeaturedServices] Querying featured_services collection...');

      final QuerySnapshot snapshot;
      if (_lastFeaturedDoc != null) {
        debugPrint(
          '[FeaturedServices] Using pagination, last doc: [33m${_lastFeaturedDoc!.id}[0m',
        );
        snapshot = await query.startAfterDocument(_lastFeaturedDoc!).get();
      } else {
        snapshot = await query.get();
      }

      debugPrint(
        '[FeaturedServices] Fetched ${snapshot.docs.length} docs from Firestore.',
      );

      if (!mounted) return;

      final newServices = snapshot.docs
          .map((doc) {
            var data = Map<String, dynamic>.from(
              doc.data() as Map<String, dynamic>,
            );
            debugPrint('[FeaturedServices] Doc ${doc.id} data: $data');
            if (data['name'] == null ||
                data['description'] == null ||
                data['price'] == null ||
                data['categoryId'] == null ||
                data['providerId'] == null ||
                data['image'] == null) {
              debugPrint(
                '[FeaturedServices] Skipping doc ${doc.id} due to missing required fields: ' +
                    [
                      if (data['name'] == null) 'name',
                      if (data['description'] == null) 'description',
                      if (data['price'] == null) 'price',
                      if (data['categoryId'] == null) 'categoryId',
                      if (data['providerId'] == null) 'providerId',
                      if (data['image'] == null) 'image',
                    ].join(', '),
              );
              return null;
            }
            data['id'] = doc.id;
            debugPrint('[FeaturedServices] Parsed service: ${data['name']}');
            return Service.fromJson(data);
          })
          .whereType<Service>()
          .toList();

      debugPrint(
        '[FeaturedServices] Parsed ${newServices.length} valid featured services.',
      );

      setState(() {
        _featuredServices.addAll(newServices);
        _isLoadingFeatured = false;
        _hasMoreFeatured = newServices.length >= 10;
        if (snapshot.docs.isNotEmpty) {
          _lastFeaturedDoc = snapshot.docs.last;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingFeatured = false;
      });
      debugPrint('[FeaturedServices] Error loading featured services: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Welcome section
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Hello, Mohammad', style: AppTextStyles.headline2),
                  const SizedBox(height: 8),
                  Text(
                    'Find the services you need',
                    style: AppTextStyles.body1.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  AppTextField(
                    controller: _searchController,
                    hint: 'Search for services...',
                    onSubmitted: _handleSearch,
                  ),
                ],
              ),
            ),
          ),

          // Promotions section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 24),
              child: SizedBox(
                height: 120,
                child: StreamBuilder<List<Promotion>>(
                  stream: _promotionsStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text('Error loading promotions'),
                      );
                    }
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final promotions = snapshot.data!;
                    if (promotions.isEmpty) {
                      return const Center(
                        child: Text('No promotions available'),
                      );
                    }
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: promotions.length,
                      itemBuilder: (context, index) {
                        final promo = promotions[index];
                        return PromoCard(
                          promotion: promo,
                          onTap: () => context.push(promo.route),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),

          // Categories section
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: SliverToBoxAdapter(
              child: SectionHeader(
                title: 'Categories',
                onSeeAll: () => context.push('/categories'),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 120,
              child: StreamBuilder<List<Category>>(
                stream: _categoriesStream,
                builder: (context, snapshot) {
                  debugPrint(
                    '[Categories] StreamBuilder called. hasData: \\${snapshot.hasData}, hasError: \\${snapshot.hasError}, connectionState: \\${snapshot.connectionState}',
                  );
                  debugPrint(
                    '[Categories] Raw snapshot: \\${snapshot.toString()}',
                  );
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    debugPrint('[Categories] Waiting for category data...');
                  }
                  if (snapshot.hasError) {
                    debugPrint(
                      '[Categories] ERROR: Type=\\${snapshot.error.runtimeType}, Value=\\${snapshot.error}',
                    );
                    debugPrint(
                      '[Categories] StackTrace: \\${snapshot.stackTrace}',
                    );
                    if (snapshot.error is Exception) {
                      debugPrint(
                        '[Categories] Exception details: \\${(snapshot.error as Exception).toString()}',
                      );
                    }
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Error loading categories',
                            style: AppTextStyles.body2.copyWith(
                              color: AppColors.error,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            snapshot.error?.toString() ?? '',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.error,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (!snapshot.hasData) {
                    debugPrint('[Categories] No category data yet.');
                    return const Center(child: CircularProgressIndicator());
                  }

                  final categories = snapshot.data!;
                  debugPrint(
                    '[Categories] Received categories: \\${categories.length}',
                  );
                  for (final cat in categories) {
                    debugPrint(
                      '[Categories] Category: id=\\${cat.id}, name=\\${cat.name}',
                    );
                  }
                  if (categories.isEmpty) {
                    debugPrint(
                      '[Categories] No categories found in Firestore.',
                    );
                    return Center(
                      child: Text(
                        'No categories available',
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return Semantics(
                        label: 'Category: \\${category.name}',
                        button: true,
                        child: CategoryCard(
                          category: category,
                          onTap: () {
                            debugPrint(
                              '[CategoryNav] Navigating to /categories/${category.id} (name: ${category.name})',
                            );
                            context.push('/categories/${category.id}');
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),

          // Featured Services section
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            sliver: SliverToBoxAdapter(
              child: SectionHeader(
                title: 'Featured Services',
                onSeeAll: () => context.push('/featured-services'),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 250,
              child: Column(
                children: [
                  Expanded(
                    child: _featuredServices.isEmpty && _isLoadingFeatured
                        ? const Center(child: CircularProgressIndicator())
                        : _featuredServices.isEmpty
                        ? Center(
                            child: Text(
                              'No featured services available',
                              style: AppTextStyles.body2.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          )
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _featuredServices.length,
                            itemBuilder: (context, index) {
                              final service = _featuredServices[index];
                              return Semantics(
                                label: 'Featured service: ${service.name}',
                                button: true,
                                child: FeaturedServiceCard(
                                  service: service,
                                  onTap: () =>
                                      context.push('/service/${service.id}'),
                                  key: ValueKey(service.id),
                                ),
                              );
                            },
                          ),
                  ),
                  if (_hasMoreFeatured)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: ElevatedButton(
                        onPressed: _isLoadingFeatured
                            ? null
                            : _loadFeaturedServices,
                        child: _isLoadingFeatured
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Load More'),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Popular Services section
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            sliver: SliverToBoxAdapter(
              child: SectionHeader(
                title: 'Popular Services',
                onSeeAll: () => context.push('/popular-services'),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: StreamBuilder<List<Service>>(
              stream: _popularServicesStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  debugPrint(
                    'Popular services stream error: ${snapshot.error}\nStack: ${snapshot.stackTrace}',
                  );
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Error loading popular services',
                            style: AppTextStyles.body2.copyWith(
                              color: AppColors.error,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            snapshot.error?.toString() ?? '',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.error,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return const SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final services = snapshot.data!.toList();

                if (services.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Text(
                        'No popular services available',
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final service = services[index];
                    return Semantics(
                      label: 'Popular service: ${service.name}',
                      button: true,
                      child: PopularServiceCard(
                        service: service,
                        onTap: () => context.push('/service/${service.id}'),
                      ),
                    );
                  }, childCount: services.length),
                );
              },
            ),
          ),

          const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
        ],
      ),
    );
  }
}
