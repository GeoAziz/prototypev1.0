import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:poafix/core/models/provider.dart';
import 'package:poafix/core/models/service.dart';
import 'package:poafix/core/models/review.dart';
import 'package:poafix/core/theme/app_colors.dart';
import 'package:poafix/core/theme/app_text_styles.dart';
import 'package:poafix/core/utils/image_helper.dart';
import 'package:poafix/core/widgets/app_button.dart';

class ProviderDetailsScreen extends StatefulWidget {
  final String providerId;
  const ProviderDetailsScreen({super.key, required this.providerId});

  @override
  State<ProviderDetailsScreen> createState() => _ProviderDetailsScreenState();
}

class _ProviderDetailsScreenState extends State<ProviderDetailsScreen>
    with TickerProviderStateMixin {
  bool _isFollowing = false;
  final int _limit = 10; // Limit for pagination

  Future<ServiceProvider?> _fetchProvider() async {
    final doc = await FirebaseFirestore.instance
        .collection('providers')
        .doc(widget.providerId)
        .get();
    if (!doc.exists) return null;
    return ServiceProvider.fromFirestore(doc);
  }

  Stream<List<Service>> _fetchProviderServices() {
    return FirebaseFirestore.instance
        .collection('services')
        .where('providerId', isEqualTo: widget.providerId)
        .orderBy('bookingCount', descending: true)
        .limit(_limit)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Service.fromJson(doc.data())).toList(),
        );
  }

  Stream<List<Review>> _fetchProviderReviews() {
    return FirebaseFirestore.instance
        .collection('reviews')
        .where('providerId', isEqualTo: widget.providerId)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Review.fromJson(doc.data())).toList(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ServiceProvider?>(
      future: _fetchProvider(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final provider = snapshot.data;
        if (provider == null) {
          return const Scaffold(
            body: Center(child: Text('Provider not found')),
          );
        }

        return DefaultTabController(
          length: 3,
          child: Scaffold(
            backgroundColor: AppColors.scaffoldBackground,
            body: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 200,
                  pinned: true,
                  leading: IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      child: const Icon(
                        Icons.arrow_back,
                        color: AppColors.white,
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  actions: [
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        child: const Icon(Icons.share, color: AppColors.white),
                      ),
                      onPressed: () {},
                    ),
                    const SizedBox(width: 8),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: double.infinity,
                          child: ImageHelper.loadNetworkImage(
                            imageUrl: provider.photo,
                            fit: BoxFit.cover,
                            placeholder: const Center(
                              child: CircularProgressIndicator(),
                            ),
                            errorWidget: const Center(child: Icon(Icons.error)),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.7),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      _buildProviderInfo(provider),
                      _buildStatsSection(provider),
                      const SizedBox(height: 24),
                      const TabBar(
                        tabs: [
                          Tab(text: 'Services'),
                          Tab(text: 'About'),
                          Tab(text: 'Reviews'),
                        ],
                        labelColor: AppColors.primary,
                        unselectedLabelColor: AppColors.textSecondary,
                        indicatorColor: AppColors.primary,
                      ),
                    ],
                  ),
                ),
                SliverFillRemaining(
                  child: TabBarView(
                    children: [
                      // Services Tab
                      StreamBuilder<List<Service>>(
                        stream: _fetchProviderServices(),
                        builder: (context, serviceSnapshot) {
                          if (serviceSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          final services = serviceSnapshot.data ?? [];
                          if (services.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.handyman_outlined,
                                    size: 64,
                                    color: AppColors.primary.withAlpha(128),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'No services available yet',
                                    style: AppTextStyles.headline3,
                                  ),
                                ],
                              ),
                            );
                          }
                          return ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: services.length,
                            itemBuilder: (context, index) {
                              final service = services[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                color: AppColors.background,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(12),
                                      ),
                                      child: ImageHelper.loadNetworkImage(
                                        imageUrl: service.image,
                                        height: 150,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            service.name,
                                            style: AppTextStyles.headline3,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            service.description,
                                            style: AppTextStyles.body2,
                                          ),
                                          const SizedBox(height: 12),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                '\$${service.price}',
                                                style: AppTextStyles.headline3
                                                    .copyWith(
                                                      color: AppColors.primary,
                                                    ),
                                              ),
                                              Expanded(
                                                child: AppButton(
                                                  text: 'Book Now',
                                                  onPressed: () {
                                                    context.push(
                                                      '/booking?serviceId=${service.id}&providerId=${provider.id}',
                                                    );
                                                  },
                                                  isFullWidth: true,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                      // About Tab
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('About', style: AppTextStyles.headline2),
                            const SizedBox(height: 16),
                            Text(provider.about, style: AppTextStyles.body2),
                          ],
                        ),
                      ),
                      // Reviews Tab
                      StreamBuilder<List<Review>>(
                        stream: _fetchProviderReviews(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          final reviews = snapshot.data ?? [];
                          if (reviews.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.star_border,
                                    size: 64,
                                    color: AppColors.primary.withValues(
                                      alpha: 128,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'No reviews yet',
                                    style: AppTextStyles.headline3,
                                  ),
                                ],
                              ),
                            );
                          }
                          return ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: reviews.length + 1,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                return _buildReviewSummary(reviews);
                              }
                              final review = reviews[index - 1];
                              return _buildReviewItem(review);
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            bottomNavigationBar: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              color: AppColors.white,
              child: Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: 'Book Now',
                      onPressed: () {
                        context.push('/booking/${provider.id}');
                      },
                      isFullWidth: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    color: _isFollowing
                        ? AppColors.lightGrey
                        : AppColors.primary.withOpacity(0.1),
                    child: IconButton(
                      icon: Icon(
                        _isFollowing ? Icons.check : Icons.add,
                        color: _isFollowing
                            ? AppColors.textSecondary
                            : AppColors.primary,
                      ),
                      onPressed: () {
                        setState(() {
                          _isFollowing = !_isFollowing;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              _isFollowing
                                  ? 'Following provider'
                                  : 'Unfollowed provider',
                            ),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProviderInfo(ServiceProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: ImageHelper.loadNetworkImage(
              imageUrl: provider.photo,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              placeholder: Container(color: AppColors.lightGrey),
              errorWidget: const Icon(Icons.error),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(provider.name, style: AppTextStyles.headline2),
                    const SizedBox(width: 8),
                    Icon(Icons.verified, color: AppColors.primary, size: 20),
                  ],
                ),
                const SizedBox(height: 4),
                Text(provider.bio, style: AppTextStyles.body2),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.star, color: AppColors.warning, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${provider.rating}',
                      style: AppTextStyles.body2.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '(${provider.reviewCount} reviews)',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(ServiceProvider provider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightGrey),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('${provider.yearsOfExperience}+', 'Years Experience'),
          _buildVerticalDivider(),
          _buildStatItem('${provider.projectsDone}+', 'Projects Done'),
          _buildVerticalDivider(),
          _buildStatItem('${provider.completionRate}%', 'Completion Rate'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(height: 40, width: 1, color: AppColors.lightGrey);
  }

  Widget _buildReviewSummary(List<Review> reviews) {
    final averageRating = reviews.isEmpty
        ? 0.0
        : reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;

    return Row(
      children: [
        Text(
          averageRating.toStringAsFixed(1),
          style: const TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RatingBar.builder(
              initialRating: averageRating,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemSize: 18,
              ignoreGestures: true,
              itemBuilder: (context, _) =>
                  const Icon(Icons.star, color: AppColors.warning),
              onRatingUpdate: (rating) {},
            ),
            const SizedBox(height: 4),
            Text(
              'Based on ${reviews.length} reviews',
              style: AppTextStyles.caption,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReviewItem(Review review) {
    String formattedDate =
        "${review.createdAt.day}/${review.createdAt.month}/${review.createdAt.year}";
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: review.userImage.isNotEmpty
                    ? ImageHelper.loadNetworkImage(
                        imageUrl: review.userImage,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 40,
                        height: 40,
                        color: AppColors.lightGrey,
                        child: const Icon(
                          Icons.person,
                          color: AppColors.primary,
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: AppTextStyles.body1.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: [
                        RatingBar.builder(
                          initialRating: review.rating,
                          minRating: 1,
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          itemCount: 5,
                          itemSize: 16,
                          ignoreGestures: true,
                          itemBuilder: (context, _) =>
                              const Icon(Icons.star, color: AppColors.warning),
                          onRatingUpdate: (rating) {},
                        ),
                        const SizedBox(width: 8),
                        Text(
                          formattedDate,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
