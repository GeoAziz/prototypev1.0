import 'package:share_plus/share_plus.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:poafix/core/models/review.dart';
import 'package:poafix/core/models/service.dart';
import 'package:poafix/core/theme/app_colors.dart';
import 'package:poafix/core/theme/app_text_styles.dart';
// Removed unused import for app_button.dart
// Removed unused import for reviews_section.dart
import 'package:poafix/features/service_details/widgets/service_image_carousel.dart';
import 'package:poafix/features/service_details/widgets/nearby_providers_section.dart';
import 'package:poafix/features/service_details/services/service_details_service.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ServiceDetailsScreen extends StatefulWidget {
  final String serviceId;

  const ServiceDetailsScreen({super.key, required this.serviceId});

  @override
  State<ServiceDetailsScreen> createState() => _ServiceDetailsScreenState();
}

class _ServiceDetailsScreenState extends State<ServiceDetailsScreen> {
  bool _isTogglingFavorite = false;
  final _service = ServiceDetailsService();
  final _auth = FirebaseAuth.instance;
  DocumentSnapshot? _lastReviewDoc;
  final List<Review> _reviews = [];
  QuerySnapshot? _lastReviewSnapshot;
  bool _isLoadingMoreReviews = false;
  bool _hasMoreReviews = true;

  @override
  void initState() {
    super.initState();
    _loadInitialReviews();
  }

  Future<void> _loadInitialReviews() async {
    int retryCount = 0;
    while (retryCount < 3) {
      try {
        final snapshot = await _service.getReviews(widget.serviceId);
        if (mounted) {
          setState(() {
            _reviews.clear();
            _reviews.addAll(_convertToReviews(snapshot));
            _lastReviewDoc = snapshot.docs.lastOrNull;
            _hasMoreReviews = snapshot.docs.length >= 5;
          });
        }
        return;
      } catch (e) {
        retryCount++;
        if (retryCount >= 3) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Failed to load reviews after 3 attempts. Please try again later. Error: $e',
                ),
              ),
            );
          }
          debugPrint('Error loading initial reviews: $e');
        }
        await Future.delayed(const Duration(seconds: 2));
      }
    }
  }

  Future<void> _loadMoreReviews() async {
    if (!_hasMoreReviews || _isLoadingMoreReviews) return;

    setState(() {
      _isLoadingMoreReviews = true;
    });

    int retryCount = 0;
    while (retryCount < 3) {
      try {
        final snapshot = await _service.getReviews(
          widget.serviceId,
          lastDoc: _lastReviewDoc,
        );

        if (mounted) {
          setState(() {
            _reviews.addAll(_convertToReviews(snapshot));
            _lastReviewDoc = snapshot.docs.lastOrNull;
            _hasMoreReviews = snapshot.docs.length >= 5;
            _isLoadingMoreReviews = false;
          });
        }
        return;
      } catch (e) {
        retryCount++;
        if (retryCount >= 3) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Failed to load more reviews after 3 attempts. Please try again later. Error: $e',
                ),
              ),
            );
          }
          debugPrint('Error loading more reviews: $e');
        }
        await Future.delayed(const Duration(seconds: 2));
      }
    }
  }

  List<Review> _convertToReviews(QuerySnapshot snapshot) {
    // Memoization: Only convert if snapshot changed
    if (_lastReviewSnapshot == snapshot && _reviews.isNotEmpty) {
      return _reviews;
    }
    _lastReviewSnapshot = snapshot;
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      // Defensive: ensure all required fields are present and non-null
      return Review.fromJson({
        'id': data['id'] ?? '',
        'serviceId': data['serviceId'] ?? '',
        'providerId': data['providerId'] ?? '',
        'userId': data['userId'] ?? '',
        'rating': data['rating'] ?? 0,
        'comment': data['comment'] ?? '',
        'createdAt': data['createdAt'] ?? Timestamp.now(),
        // Add other fields as needed, always with defaults
      });
    }).toList();
  }

  Future<void> _toggleFavorite() async {
    setState(() {
      _isTogglingFavorite = true;
    });
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        context.push('/login');
        setState(() {
          _isTogglingFavorite = false;
        });
        return;
      }
      await _service.toggleFavorite(widget.serviceId, userId);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating favorite: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isTogglingFavorite = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Service?>(
      stream: _service.streamService(widget.serviceId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text(
                'Error loading service: ${snapshot.error}',
                style: AppTextStyles.body1.copyWith(color: AppColors.error),
              ),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final service = snapshot.data;
        if (service == null) {
          return Scaffold(
            body: Center(
              child: Text(
                'Service not found',
                style: AppTextStyles.body1.copyWith(color: AppColors.error),
              ),
            ),
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final isTablet = constraints.maxWidth > 600;
            final horizontalPadding = isTablet ? 32.0 : 16.0;
            final headlineFontSize = isTablet ? 28.0 : 22.0;
            final bodyFontSize = isTablet ? 18.0 : 14.0;
            return Scaffold(
              backgroundColor: AppColors.scaffoldBackground,
              body: Stack(
                children: [
                  NotificationListener<ScrollNotification>(
                    onNotification: (scrollInfo) {
                      if (!_isLoadingMoreReviews &&
                          _hasMoreReviews &&
                          scrollInfo.metrics.pixels >=
                              scrollInfo.metrics.maxScrollExtent - 200) {
                        _loadMoreReviews();
                      }
                      return false;
                    },
                    child: RefreshIndicator(
                      onRefresh: _loadInitialReviews,
                      child: CustomScrollView(
                        slivers: [
                          // App Bar with Image Carousel
                          SliverAppBar(
                            expandedHeight: isTablet ? 400 : 300,
                            pinned: true,
                            leading: Semantics(
                              label: 'Back',
                              button: true,
                              child: Container(
                                margin: EdgeInsets.all(horizontalPadding / 2),
                                decoration: BoxDecoration(
                                  color: AppColors.white.withOpacity(0.8),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.arrow_back),
                                  onPressed: () => context.pop(),
                                ),
                              ),
                            ),
                            actions: [
                              Semantics(
                                label: 'Share',
                                button: true,
                                child: IconButton(
                                  icon: const Icon(Icons.share),
                                  onPressed: () {
                                    final priceText = service.priceMax != null
                                        ? 'KES ${service.price.toStringAsFixed(0)} - ${service.priceMax!.toStringAsFixed(0)}${service.pricingType == 'hourly'
                                              ? "/hr"
                                              : service.pricingType == 'per_unit'
                                              ? "/unit"
                                              : ''}'
                                        : 'KES ${service.price.toStringAsFixed(0)}${service.pricingType == 'hourly'
                                              ? "/hr"
                                              : service.pricingType == 'per_unit'
                                              ? "/unit"
                                              : ''}';
                                    final shareText =
                                        'Check out this service: ${service.name}\n${service.description}\nPrice: $priceText\n';
                                    Share.share(shareText);
                                  },
                                ),
                              ),
                              Semantics(
                                label: 'Favorite',
                                button: true,
                                child: StreamBuilder<bool>(
                                  stream: _service.isFavorited(
                                    widget.serviceId,
                                    _auth.currentUser?.uid ?? '',
                                  ),
                                  builder: (context, favSnapshot) {
                                    final isFavorited =
                                        favSnapshot.data ?? false;
                                    return _isTogglingFavorite
                                        ? const Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            ),
                                          )
                                        : IconButton(
                                            icon: Icon(
                                              isFavorited
                                                  ? Icons.favorite
                                                  : Icons.favorite_border,
                                              color: isFavorited
                                                  ? AppColors.primary
                                                  : null,
                                            ),
                                            onPressed: _toggleFavorite,
                                          );
                                  },
                                ),
                              ),
                            ],
                            flexibleSpace: FlexibleSpaceBar(
                              background: Semantics(
                                label:
                                    'Service images carousel for ${service.name}',
                                child: ServiceImageCarousel(
                                  images: service.images ?? [],
                                ),
                              ),
                            ),
                          ),

                          // Service Details
                          SliverToBoxAdapter(
                            child: Container(
                              padding: EdgeInsets.all(horizontalPadding),
                              color: AppColors.white,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Service Name & Price
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Semantics(
                                          label:
                                              'Service name: ${service.name}',
                                          child: Text(
                                            service.name,
                                            style: AppTextStyles.headline2
                                                .copyWith(
                                                  fontSize: headlineFontSize,
                                                ),
                                          ),
                                        ),
                                      ),
                                      Semantics(
                                        label:
                                            'Service price: ${service.price}',
                                        child: Text(
                                          service.priceMax != null
                                              ? 'KES ${service.price.toStringAsFixed(0)} - ${service.priceMax!.toStringAsFixed(0)}${service.pricingType == 'hourly'
                                                    ? "/hr"
                                                    : service.pricingType == 'per_unit'
                                                    ? "/unit"
                                                    : ''}'
                                              : 'KES ${service.price.toStringAsFixed(0)}${service.pricingType == 'hourly'
                                                    ? "/hr"
                                                    : service.pricingType == 'per_unit'
                                                    ? "/unit"
                                                    : ''}',
                                          style: AppTextStyles.headline2
                                              .copyWith(
                                                color: AppColors.primary,
                                                fontSize: headlineFontSize,
                                              ),
                                        ),
                                      ),
                                      if (service.categoryName.isNotEmpty)
                                        Text(
                                          service.categoryName,
                                          style: AppTextStyles.caption,
                                        ),
                                      if (service.subService.isNotEmpty)
                                        Text(
                                          service.subService,
                                          style: AppTextStyles.caption,
                                        ),
                                    ],
                                  ),
                                  SizedBox(height: isTablet ? 20 : 12),
                                  // Rating
                                  Row(
                                    children: [
                                      Semantics(
                                        label:
                                            'Service rating: ${service.rating} out of 5',
                                        child: RatingBar.builder(
                                          initialRating: service.rating,
                                          minRating: 1,
                                          direction: Axis.horizontal,
                                          allowHalfRating: true,
                                          itemCount: 5,
                                          itemSize: isTablet ? 28 : 18,
                                          ignoreGestures: true,
                                          itemBuilder: (context, _) =>
                                              const Icon(
                                                Icons.star,
                                                color: Colors.amber,
                                              ),
                                          onRatingUpdate: (rating) {},
                                        ),
                                      ),
                                      SizedBox(width: isTablet ? 16 : 8),
                                      Semantics(
                                        label:
                                            'Total reviews: ${service.reviewCount}',
                                        child: Text(
                                          '${service.rating} (${service.reviewCount} reviews)',
                                          style: AppTextStyles.body2.copyWith(
                                            fontSize: bodyFontSize,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: isTablet ? 24 : 16),
                                  const Divider(),
                                  SizedBox(height: isTablet ? 24 : 16),
                                  // Description
                                  Text(
                                    'Description',
                                    style: AppTextStyles.headline3.copyWith(
                                      fontSize: headlineFontSize,
                                    ),
                                  ),
                                  SizedBox(height: isTablet ? 12 : 8),
                                  Text(
                                    service.description,
                                    style: AppTextStyles.body1.copyWith(
                                      fontSize: bodyFontSize,
                                    ),
                                  ),
                                  SizedBox(height: isTablet ? 32 : 24),
                                  // Features
                                  Text(
                                    'What\'s Included',
                                    style: AppTextStyles.headline3.copyWith(
                                      fontSize: headlineFontSize,
                                    ),
                                  ),
                                  SizedBox(height: isTablet ? 20 : 12),
                                  ...service.features.map(
                                    (feature) => Padding(
                                      padding: EdgeInsets.only(
                                        bottom: isTablet ? 12 : 8,
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.check_circle,
                                            color: AppColors.success,
                                            size: 20,
                                          ),
                                          SizedBox(width: isTablet ? 20 : 12),
                                          Expanded(
                                            child: Text(
                                              feature,
                                              style: AppTextStyles.body1
                                                  .copyWith(
                                                    fontSize: bodyFontSize,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Available Providers Section
                          SliverToBoxAdapter(
                            child: Container(
                              margin: EdgeInsets.only(top: isTablet ? 16 : 8),
                              child: NearbyProvidersSection(
                                serviceId: service.id,
                                serviceCategoryName: service.categoryName,
                                radius: 10.0, // 10km radius
                              ),
                            ),
                          ),
                          // Bottom space for button
                          SliverToBoxAdapter(
                            child: SizedBox(height: isTablet ? 120 : 80),
                          ),
                        ],
                      ), // CustomScrollView
                    ), // RefreshIndicator
                  ), // NotificationListener
                ], // Stack children
              ), // Stack
            ); // Scaffold
          },
        ); // LayoutBuilder
      },
    ); // StreamBuilder
  }
}
