import 'package:flutter/material.dart';
import 'package:poafix/core/models/review.dart';
import 'package:poafix/core/theme/app_colors.dart';
import 'package:poafix/core/theme/app_text_styles.dart';
import 'review_card.dart';

class ReviewsSection extends StatelessWidget {
  final List<Review> reviews;
  final bool hasMoreReviews;
  final bool isLoadingMoreReviews;
  final VoidCallback? onLoadMore;
  final VoidCallback? onSeeAll;

  const ReviewsSection({
    super.key,
    required this.reviews,
    required this.hasMoreReviews,
    required this.isLoadingMoreReviews,
    this.onLoadMore,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      color: AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Reviews', style: AppTextStyles.headline3),
              TextButton(
                onPressed: onSeeAll,
                child: Text(
                  'See All',
                  style: AppTextStyles.body2.copyWith(color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (reviews.isEmpty)
            Text('No reviews yet.', style: AppTextStyles.body2),
          ...reviews.take(3).map((review) => ReviewCard(review: review)),
          if (reviews.length >= 3 && hasMoreReviews)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Center(
                child: TextButton(
                  onPressed: isLoadingMoreReviews ? null : onLoadMore,
                  child: isLoadingMoreReviews
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Load More'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
