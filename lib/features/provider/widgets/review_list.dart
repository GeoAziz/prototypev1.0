import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// ...existing code...
import '../providers/review_provider.dart';
import 'review_card.dart';
import '../models/review_model.dart'; // Correct import for ReviewStats and ReviewQueryOptions

class ReviewsList extends ConsumerStatefulWidget {
  final String providerId;
  final bool isProvider;
  final String currentUserId;
  final ScrollController? scrollController;

  const ReviewsList({
    Key? key,
    required this.providerId,
    this.isProvider = false,
    required this.currentUserId,
    this.scrollController,
  }) : super(key: key);

  @override
  ConsumerState<ReviewsList> createState() => _ReviewsListState();
}

class _ReviewsListState extends ConsumerState<ReviewsList> {
  @override
  void initState() {
    super.initState();
    _loadInitialReviews();

    widget.scrollController?.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.scrollController?.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    if (widget.scrollController == null) return;

    final maxScroll = widget.scrollController!.position.maxScrollExtent;
    final currentScroll = widget.scrollController!.position.pixels;
    const threshold = 200.0;

    if (maxScroll - currentScroll <= threshold) {
      _loadMoreReviews();
    }
  }

  Future<void> _loadInitialReviews() async {
    final options = ReviewQueryOptions(providerId: widget.providerId);
    await ref
        .read(reviewProvider.notifier)
        .loadReviews(options: options, refresh: true);
  }

  Future<void> _loadMoreReviews() async {
    final state = ref.read(reviewProvider);
    if (!state.hasMoreReviews || state.isLoading) return;

    await ref
        .read(reviewProvider.notifier)
        .loadReviews(options: state.currentOptions);
  }

  @override
  Widget build(BuildContext context) {
    final reviewsState = ref.watch(reviewProvider);

    return Stack(
      children: [
        ListView.builder(
          controller: widget.scrollController,
          itemCount: reviewsState.reviews.length + 1,
          itemBuilder: (context, index) {
            if (index == reviewsState.reviews.length) {
              if (reviewsState.isLoading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              if (!reviewsState.hasMoreReviews) {
                return const SizedBox.shrink();
              }
              return const SizedBox(height: 60);
            }

            final review = reviewsState.reviews[index];
            return ReviewCard(
              review: review,
              isProvider: widget.isProvider,
              currentUserId: widget.currentUserId,
            );
          },
        ),
        if (reviewsState.error != null)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Material(
              color: Theme.of(context).colorScheme.error,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  reviewsState.error!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onError,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ...existing code...

class ReviewStatsWidget extends ConsumerWidget {
  final String providerId;

  const ReviewStatsWidget({super.key, required this.providerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(reviewStatsStreamProvider(providerId));

    return statsAsync.when(
      data: (stats) => _buildStats(context, stats),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) =>
          Center(child: Text('Error loading stats: $error')),
    );
  }

  Widget _buildStats(BuildContext context, ReviewStats stats) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  stats.averageRating.toStringAsFixed(1),
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RatingStars(rating: stats.averageRating),
                    Text(
                      '${stats.totalReviews} reviews',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            for (var i = 5; i >= 1; i--)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Text('$i'),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: stats.getPercentageForRating(i) / 100,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation(
                            Theme.of(context).colorScheme.primary,
                          ),
                          minHeight: 8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 40,
                      child: Text(
                        '${stats.ratingDistribution[i] ?? 0}',
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  context,
                  'Verified',
                  stats.verifiedCount,
                  Icons.verified_user,
                ),
                _buildStatItem(
                  context,
                  'Helpful',
                  stats.helpfulCount,
                  Icons.thumb_up,
                ),
                _buildStatItem(
                  context,
                  'Responses',
                  stats.responseCount,
                  Icons.reply,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    int count,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, size: 20),
        const SizedBox(height: 4),
        Text(count.toString(), style: Theme.of(context).textTheme.titleMedium),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
