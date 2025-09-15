import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:poafix/core/theme/app_colors.dart';
import 'package:poafix/core/theme/app_text_styles.dart';
import 'package:poafix/core/utils/image_helper.dart';
import 'package:poafix/core/widgets/app_button.dart';

class ServiceReviewsScreen extends StatefulWidget {
  final String serviceId;

  const ServiceReviewsScreen({super.key, required this.serviceId});

  @override
  State<ServiceReviewsScreen> createState() => _ServiceReviewsScreenState();
}

class _ServiceReviewsScreenState extends State<ServiceReviewsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reviews & Ratings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'All Reviews'),
            Tab(text: '5 Star'),
            Tab(text: '3-4 Star'),
            Tab(text: '1-2 Star'),
          ],
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildRatingSummary(),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildReviewsList(null),
                _buildReviewsList(5),
                _buildReviewsList(3),
                _buildReviewsList(1),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: AppButton(
            text: 'Write a Review',
            onPressed: () {
              _showWriteReviewBottomSheet();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildRatingSummary() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '4.8',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              RatingBar.builder(
                initialRating: 4.8,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemSize: 20,
                ignoreGestures: true,
                itemBuilder: (context, _) =>
                    const Icon(Icons.star, color: AppColors.warning),
                onRatingUpdate: (rating) {},
              ),
              const SizedBox(height: 8),
              Text('Based on 256 reviews', style: AppTextStyles.caption),
            ],
          ),
        ),
        Expanded(
          flex: 3,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildRatingBar(5, 180),
              _buildRatingBar(4, 40),
              _buildRatingBar(3, 20),
              _buildRatingBar(2, 10),
              _buildRatingBar(1, 6),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRatingBar(int stars, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$stars', style: AppTextStyles.body2),
          const Icon(Icons.star, size: 14, color: AppColors.warning),
          const SizedBox(width: 8),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.lightGrey,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth * (count / 256);
                    return Container(
                      height: 6,
                      width: width,
                      decoration: BoxDecoration(
                        color: AppColors.warning,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text('$count', style: AppTextStyles.caption),
        ],
      ),
    );
  }

  Widget _buildReviewsList(int? starFilter) {
    // Mock reviews data
    final reviews = [
      {
        'name': 'Alex Johnson',
        'image': 'https://images.unsplash.com/photo-1568602471122-7832951cc4c5',
        'rating': 5,
        'date': '2 days ago',
        'comment':
            'The service was excellent! The technician was very professional and fixed my AC in no time. Highly recommend!',
        'images': [
          'https://img.icons8.com/?size=100&id=12237&format=png&color=000000',
          'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d',
        ],
      },
      {
        'name': 'Sarah Miller',
        'image': 'https://images.unsplash.com/photo-1580489944761-15a19d654956',
        'rating': 4,
        'date': '1 week ago',
        'comment':
            'Good service overall. Technician was knowledgeable and fixed the issue, though arrived a bit late.',
        'images': [],
      },
      {
        'name': 'Michael Chen',
        'image': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d',
        'rating': 5,
        'date': '2 weeks ago',
        'comment':
            'Very satisfied with the cleaning service. They were thorough and paid attention to detail. Will use again!',
        'images': [
          'https://images.unsplash.com/photo-1626722889113-c7723d373c27',
        ],
      },
      {
        'name': 'Emily Wilson',
        'image': 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80',
        'rating': 3,
        'date': '3 weeks ago',
        'comment':
            'Service was okay. The technician did the job but wasn\'t very communicative about what needed to be done.',
        'images': [],
      },
      {
        'name': 'David Thompson',
        'image': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e',
        'rating': 2,
        'date': '1 month ago',
        'comment':
            'Disappointed with the service. The technician was late and didn\'t fix the issue completely. Had to call again.',
        'images': [],
      },
    ];

    final filteredReviews = starFilter == null
        ? reviews
        : reviews.where((review) {
            final rating = review['rating'] as int;
            if (starFilter == 5) return rating == 5;
            if (starFilter == 3) return rating >= 3 && rating <= 4;
            return rating <= 2;
          }).toList();

    if (filteredReviews.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.rate_review_outlined,
              size: 64,
              color: AppColors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No reviews in this category yet',
              style: AppTextStyles.body1.copyWith(color: AppColors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: filteredReviews.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final review = filteredReviews[index];
        return _buildReviewItem(review);
      },
    );
  }

  Widget _buildReviewItem(Map<String, dynamic> review) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: ImageHelper.loadNetworkImage(
                imageUrl: review['image'] as String,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                placeholder: Container(color: AppColors.lightGrey),
                errorWidget: const Icon(Icons.person),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  review['name'] as String,
                  style: AppTextStyles.body1.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(review['date'] as String, style: AppTextStyles.caption),
              ],
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${review['rating']}',
                    style: AppTextStyles.body2.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.warning,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.star, size: 14, color: AppColors.warning),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(review['comment'] as String, style: AppTextStyles.body2),
        const SizedBox(height: 12),
        _buildReviewImages(review['images'] as List),
        const SizedBox(height: 8),
        Row(
          children: [
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.thumb_up_alt_outlined, size: 16),
              label: const Text('Helpful'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                visualDensity: VisualDensity.compact,
              ),
            ),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.flag_outlined, size: 16),
              label: const Text('Report'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReviewImages(List images) {
    if (images.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                // Show full-screen image viewer
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: ImageHelper.loadNetworkImage(
                  imageUrl: images[index] as String,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showWriteReviewBottomSheet() {
    double rating = 0;
    final commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Write a Review', style: AppTextStyles.headline3),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Column(
                      children: [
                        const Text(
                          'How was your experience?',
                          style: AppTextStyles.body1,
                        ),
                        const SizedBox(height: 12),
                        RatingBar.builder(
                          initialRating: 0,
                          minRating: 1,
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          itemCount: 5,
                          itemSize: 36,
                          glow: false,
                          itemPadding: const EdgeInsets.symmetric(
                            horizontal: 4.0,
                          ),
                          itemBuilder: (context, _) =>
                              const Icon(Icons.star, color: AppColors.warning),
                          onRatingUpdate: (value) {
                            setState(() {
                              rating = value;
                            });
                          },
                        ),
                        const SizedBox(height: 8),
                        Text(
                          rating > 0 ? _getRatingText(rating) : 'Tap to rate',
                          style: AppTextStyles.body2.copyWith(
                            color: rating > 0
                                ? AppColors.warning
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: commentController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'Tell us more about your experience...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(
                        Icons.camera_alt_outlined,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Add Photos',
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: AppButton(
                      text: 'Submit Review',
                      onPressed: () {
                        if (rating > 0) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Review submitted successfully!'),
                            ),
                          );
                        }
                      },
                      backgroundColor: rating > 0
                          ? AppColors.primary
                          : AppColors.grey,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _getRatingText(double rating) {
    if (rating >= 5) return 'Excellent';
    if (rating >= 4) return 'Very Good';
    if (rating >= 3) return 'Good';
    if (rating >= 2) return 'Fair';
    return 'Poor';
  }
}
