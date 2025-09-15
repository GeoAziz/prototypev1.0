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
  final _serviceService = ServiceService();
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
    _popularServicesStream = _serviceService.streamServices(
      isPopular: true,
      limit: 10,
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
          .collection('services')
          .where('isFeatured', isEqualTo: true)
          .orderBy('bookingCount', descending: true)
          .limit(10);

      final QuerySnapshot snapshot;
      if (_lastFeaturedDoc != null) {
        snapshot = await query.startAfterDocument(_lastFeaturedDoc!).get();
      } else {
        snapshot = await query.get();
      }

      if (!mounted) return;

      final newServices = snapshot.docs
          .map((doc) {
            var data = Map<String, dynamic>.from(
              doc.data() as Map<String, dynamic>,
            );
            // Ensure all required fields are present and not null
            if (data['name'] == null ||
                data['description'] == null ||
                data['price'] == null ||
                data['categoryId'] == null ||
                data['providerId'] == null ||
                data['image'] == null) {
              debugPrint(
                'Skipping service doc ${doc.id} due to missing required fields',
              );
              return null;
            }
            data['id'] = doc.id;
            return Service.fromJson(data);
          })
          .whereType<Service>()
          .toList();

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
      // Use proper logging instead of print
      debugPrint('Error loading featured services: $e');
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
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error loading categories',
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    );
                  }

                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final categories = snapshot.data!;
                  if (categories.isEmpty) {
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
                        label: 'Category: ${category.name}',
                        button: true,
                        child: CategoryCard(
                          category: category,
                          onTap: () =>
                              context.push('/categories/${category.id}'),
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
                                      context.push('/services/${service.id}'),
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
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Text(
                        'Error loading popular services',
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return const SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final services = snapshot.data!
                    .where(
                      (service) =>
                          service.name != null &&
                          service.description != null &&
                          service.price != null &&
                          service.categoryId != null &&
                          service.providerId != null &&
                          service.image != null,
                    )
                    .toList();

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
                        onTap: () => context.push('/services/${service.id}'),
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
