import 'package:flutter/material.dart';

class RecentReviewsWidget extends StatelessWidget {
  const RecentReviewsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Reviews',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to all reviews
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildReviewsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsList() {
    // Mock reviews data
    final reviews = [
      _Review(
        customerName: 'Alice Johnson',
        rating: 5,
        comment: 'Excellent service! Very professional and thorough.',
        date: '2 days ago',
      ),
      _Review(
        customerName: 'Bob Wilson',
        rating: 4,
        comment: 'Good work, but arrived a bit late.',
        date: '1 week ago',
      ),
    ];

    return Column(
      children: List.generate(
        reviews.length,
        (index) => _buildReviewCard(
          reviews[index],
          isLast: index == reviews.length - 1,
        ),
      ),
    );
  }

  Widget _buildReviewCard(_Review review, {required bool isLast}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                review.customerName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                review.date,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              ...List.generate(
                5,
                (index) => Icon(
                  index < review.rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(review.comment),
          if (!isLast) const Divider(height: 32),
        ],
      ),
    );
  }
}

class _Review {
  final String customerName;
  final int rating;
  final String comment;
  final String date;

  _Review({
    required this.customerName,
    required this.rating,
    required this.comment,
    required this.date,
  });
}
