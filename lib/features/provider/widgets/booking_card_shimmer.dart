import 'package:flutter/material.dart';
import '../../../core/widgets/shimmer_loading.dart';

class BookingCardShimmer extends StatelessWidget {
  const BookingCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                ShimmerLoading.circular(width: 40, height: 40),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerLoading.rectangular(
                        height: 20,
                        width: MediaQuery.of(context).size.width * 0.3,
                      ),
                      const SizedBox(height: 8),
                      ShimmerLoading.rectangular(
                        height: 16,
                        width: MediaQuery.of(context).size.width * 0.5,
                      ),
                    ],
                  ),
                ),
                ShimmerLoading.rectangular(height: 24, width: 80),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ShimmerLoading.rectangular(height: 36, width: 100),
                ShimmerLoading.rectangular(height: 36, width: 100),
                ShimmerLoading.rectangular(height: 36, width: 100),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
