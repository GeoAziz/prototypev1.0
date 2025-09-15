import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:poafix/core/theme/app_colors.dart';
import 'package:poafix/core/theme/app_text_styles.dart';
import 'package:poafix/core/utils/image_helper.dart';
import 'package:poafix/core/widgets/app_button.dart';

class ServiceProviderScreen extends StatefulWidget {
  final String providerId;

  const ServiceProviderScreen({super.key, required this.providerId});

  @override
  State<ServiceProviderScreen> createState() => _ServiceProviderScreenState();
}

class _ServiceProviderScreenState extends State<ServiceProviderScreen> {
  bool _isFollowing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProviderInfo(),
                _buildStatsSection(),
                _buildTabSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.arrow_back, color: AppColors.white),
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(8),
            ),
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
                imageUrl:
                    'https://images.unsplash.com/photo-1578845510185-8dc44be38359',
                fit: BoxFit.cover,
                placeholder: const Center(child: CircularProgressIndicator()),
                errorWidget: const Center(child: Icon(Icons.error)),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderInfo() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: ImageHelper.loadNetworkImage(
                  imageUrl:
                      'https://images.unsplash.com/photo-1607346256330-dee7af15f7c5',
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
                        const Text(
                          'ServicePro Solutions',
                          style: AppTextStyles.headline2,
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.verified,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Home Repair & Maintenance',
                      style: AppTextStyles.body2,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: AppColors.warning,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          '4.9',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(256 reviews)',
                          style: AppTextStyles.body2.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            context.push('/services/123/reviews');
                          },
                          child: Text(
                            'See all',
                            style: AppTextStyles.body2.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: 'Book Now',
                  onPressed: () {
                    context.push('/booking/123');
                  },
                ),
              ),
              const SizedBox(width: 16),
              Container(
                decoration: BoxDecoration(
                  color: _isFollowing
                      ? AppColors.lightGrey
                      : AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
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
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
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
          _buildStatItem('5+', 'Years Experience'),
          _buildVerticalDivider(),
          _buildStatItem('120+', 'Projects Done'),
          _buildVerticalDivider(),
          _buildStatItem('95%', 'Completion Rate'),
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

  Widget _buildTabSection() {
    return DefaultTabController(
      length: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: TabBar(
              tabs: [
                Tab(text: 'Services'),
                Tab(text: 'About'),
                Tab(text: 'Reviews'),
              ],
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
            ),
          ),
          SizedBox(
            height: 600, // Fixed height for demo purposes
            child: TabBarView(
              children: [
                _buildServicesTab(),
                _buildAboutTab(),
                _buildReviewsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesTab() {
    final services = [
      {
        'title': 'Basic Plumbing Service',
        'image': 'https://images.unsplash.com/photo-1524913954112-3a7a4d392a2c',
        'price': '\$45',
        'duration': '1 hour',
        'rating': 4.8,
      },
      {
        'title': 'Electrical Repair & Installation',
        'image': 'https://images.unsplash.com/photo-1621905252507-b35492cc74b4',
        'price': '\$60',
        'duration': '2 hours',
        'rating': 4.9,
      },
      {
        'title': 'Furniture Assembly',
        'image': 'https://images.unsplash.com/photo-1556228453-efd6c1ff04f6',
        'price': '\$50',
        'duration': '1.5 hours',
        'rating': 4.7,
      },
      {
        'title': 'Wall Painting',
        'image':
            'https://img.icons8.com/?size=100&id=9fS8epYOUvtK&format=png&color=000000',
        'price': '\$120',
        'duration': '4 hours',
        'rating': 4.9,
      },
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: services.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final service = services[index];
        return GestureDetector(
          onTap: () {
            context.push('/services/123');
          },
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: ImageHelper.loadNetworkImage(
                    imageUrl: service['image'] as String,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service['title'] as String,
                        style: AppTextStyles.headline3,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            service['duration'] as String,
                            style: AppTextStyles.body2.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Icon(
                            Icons.star,
                            size: 16,
                            color: AppColors.warning,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${service['rating']}',
                            style: AppTextStyles.body2,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            service['price'] as String,
                            style: AppTextStyles.price,
                          ),
                          ElevatedButton(
                            onPressed: () {
                              context.push('/booking/123');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                            child: const Text('Book Now'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAboutTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'About ServicePro Solutions',
            style: AppTextStyles.headline3,
          ),
          const SizedBox(height: 16),
          const Text(
            'ServicePro Solutions is a leading provider of home repair and maintenance services with over 5 years of experience in the industry. We specialize in plumbing, electrical work, furniture assembly, and painting services.\n\nOur team of skilled professionals is dedicated to delivering high-quality service with attention to detail and customer satisfaction as our top priority. We take pride in our work and strive to exceed your expectations with every project.',
            style: AppTextStyles.body2,
          ),
          const SizedBox(height: 24),
          const Text('Work Hours', style: AppTextStyles.headline3),
          const SizedBox(height: 8),
          _buildWorkHoursItem('Monday - Friday', '8:00 AM - 6:00 PM'),
          _buildWorkHoursItem('Saturday', '9:00 AM - 4:00 PM'),
          _buildWorkHoursItem('Sunday', 'Closed'),

          const SizedBox(height: 24),
          const Text('Service Areas', style: AppTextStyles.headline3),
          const SizedBox(height: 8),
          _buildAreaItem('Downtown', '15 min response time'),
          _buildAreaItem('Eastside', '20 min response time'),
          _buildAreaItem('Westside', '25 min response time'),
          _buildAreaItem('Northside', '30 min response time'),
          _buildAreaItem('Southside', '35 min response time'),

          const SizedBox(height: 24),
          const Text('Contact Information', style: AppTextStyles.headline3),
          const SizedBox(height: 16),
          _buildContactItem(
            Icons.email_outlined,
            'Email',
            'info@servicepro.com',
          ),
          _buildContactItem(Icons.phone_outlined, 'Phone', '+1 (555) 123-4567'),
          _buildContactItem(
            Icons.location_on_outlined,
            'Address',
            '123 Service St, City, State',
          ),
          _buildContactItem(
            Icons.language_outlined,
            'Website',
            'www.servicepro.com',
          ),
        ],
      ),
    );
  }

  Widget _buildWorkHoursItem(String day, String hours) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(day, style: AppTextStyles.body2),
          Text(
            hours,
            style: AppTextStyles.body2.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildAreaItem(String area, String response) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(
            Icons.location_on_outlined,
            size: 16,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          Text(area, style: AppTextStyles.body2),
          const Spacer(),
          Text(
            response,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(value, style: AppTextStyles.body2),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsTab() {
    // Display a summary of reviews with a button to see all reviews
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildReviewSummary(),
          const SizedBox(height: 24),
          _buildReviewItem(
            name: 'John Smith',
            image:
                'https://images.unsplash.com/photo-1568602471122-7832951cc4c5',
            rating: 5,
            date: '3 days ago',
            comment:
                'Amazing service! The technician was on time, professional, and fixed my plumbing issue quickly. Highly recommended!',
          ),
          const Divider(),
          _buildReviewItem(
            name: 'Emma Johnson',
            image:
                'https://images.unsplash.com/photo-1580489944761-15a19d654956',
            rating: 4,
            date: '1 week ago',
            comment:
                'Great service overall. The electrician was knowledgeable and did a good job. Would use their services again.',
          ),
          const Divider(),
          _buildReviewItem(
            name: 'Michael Lee',
            image:
                'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d',
            rating: 5,
            date: '2 weeks ago',
            comment:
                'Excellent furniture assembly service. The technician was careful and efficient. Everything works perfectly!',
          ),
          const SizedBox(height: 24),
          AppButton(
            text: 'See All Reviews',
            onPressed: () {
              context.push('/services/123/reviews');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReviewSummary() {
    return Row(
      children: [
        const Text(
          '4.9',
          style: TextStyle(
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
              initialRating: 4.9,
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
            Text('Based on 256 reviews', style: AppTextStyles.caption),
          ],
        ),
      ],
    );
  }

  Widget _buildReviewItem({
    required String name,
    required String image,
    required int rating,
    required String date,
    required String comment,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: ImageHelper.loadNetworkImage(
                  imageUrl: image,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTextStyles.body1.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: [
                        RatingBar.builder(
                          initialRating: rating.toDouble(),
                          minRating: 1,
                          direction: Axis.horizontal,
                          allowHalfRating: false,
                          itemCount: 5,
                          itemSize: 14,
                          ignoreGestures: true,
                          itemBuilder: (context, _) =>
                              const Icon(Icons.star, color: AppColors.warning),
                          onRatingUpdate: (rating) {},
                        ),
                        const SizedBox(width: 8),
                        Text(
                          date,
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
          const SizedBox(height: 8),
          Text(comment, style: AppTextStyles.body2),
        ],
      ),
    );
  }
}
