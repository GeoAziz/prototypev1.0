import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/review_model.dart';
import '../repositories/review_repository.dart';

class ReviewState {
  final List<Review> reviews;
  final bool isLoading;
  final String? error;
  final ReviewStats stats;
  final bool hasMoreReviews;
  final DocumentSnapshot? lastDocument;
  final ReviewQueryOptions currentOptions;

  const ReviewState({
    this.reviews = const [],
    this.isLoading = false,
    this.error,
    this.stats = const ReviewStats(
      averageRating: 0,
      totalReviews: 0,
      ratingDistribution: {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
      helpfulCount: 0,
      verifiedCount: 0,
      responseCount: 0,
    ),
    this.hasMoreReviews = true,
    this.lastDocument,
    this.currentOptions = const ReviewQueryOptions(),
  });

  ReviewState copyWith({
    List<Review>? reviews,
    bool? isLoading,
    String? error,
    ReviewStats? stats,
    bool? hasMoreReviews,
    DocumentSnapshot? lastDocument,
    ReviewQueryOptions? currentOptions,
  }) {
    return ReviewState(
      reviews: reviews ?? this.reviews,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      stats: stats ?? this.stats,
      hasMoreReviews: hasMoreReviews ?? this.hasMoreReviews,
      lastDocument: lastDocument ?? this.lastDocument,
      currentOptions: currentOptions ?? this.currentOptions,
    );
  }
}

class ReviewNotifier extends StateNotifier<ReviewState> {
  final ReviewRepository _repository;

  ReviewNotifier(this._repository) : super(const ReviewState());

  Future<void> loadReviews({
    ReviewQueryOptions options = const ReviewQueryOptions(),
    bool refresh = false,
  }) async {
    if (state.isLoading) return;

    try {
      state = state.copyWith(isLoading: true);

      final effectiveOptions = refresh
          ? options
          : options.copyWith(startAfter: state.lastDocument);

      final snapshot = await _repository.getReviews(effectiveOptions);
      final reviews = snapshot.docs
          .map((doc) => Review.fromJson(doc.data()))
          .toList();

      // Load stats if this is a provider-specific query
      if (options.providerId != null) {
        final stats = await _repository.getReviewStats(options.providerId!);
        state = state.copyWith(stats: stats);
      }

      state = state.copyWith(
        reviews: refresh ? reviews : [...state.reviews, ...reviews],
        isLoading: false,
        hasMoreReviews: reviews.length >= effectiveOptions.limit,
        lastDocument: snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
        currentOptions: effectiveOptions,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load reviews: $e',
      );
    }
  }

  Future<void> createReview({
    required String providerId,
    required String userId,
    required String userName,
    required String userAvatar,
    required double rating,
    required String comment,
    Map<String, dynamic>? media,
    bool isVerifiedBooking = false,
  }) async {
    try {
      state = state.copyWith(isLoading: true);

      await _repository.createReview(
        providerId: providerId,
        userId: userId,
        userName: userName,
        userAvatar: userAvatar,
        rating: rating,
        comment: comment,
        media: media,
        isVerifiedBooking: isVerifiedBooking,
      );

      // Refresh the reviews list
      await loadReviews(options: state.currentOptions, refresh: true);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to create review: $e',
      );
    }
  }

  Future<void> toggleHelpful(String reviewId, String userId) async {
    try {
      final review = state.reviews.firstWhere((r) => r.id == reviewId);
      final isHelpful = review.isHelpfulToUser(userId);

      if (isHelpful) {
        await _repository.unmarkReviewHelpful(reviewId, userId);
      } else {
        await _repository.markReviewHelpful(reviewId, userId);
      }

      // Refresh the reviews list
      await loadReviews(options: state.currentOptions, refresh: true);
    } catch (e) {
      state = state.copyWith(error: 'Failed to update helpful status: $e');
    }
  }

  Future<void> addResponse(
    String reviewId,
    Map<String, dynamic> response,
  ) async {
    try {
      await _repository.addResponse(reviewId, response);
      // Refresh the reviews list
      await loadReviews(options: state.currentOptions, refresh: true);
    } catch (e) {
      state = state.copyWith(error: 'Failed to add response: $e');
    }
  }

  Future<void> flagReview(String reviewId, String reason) async {
    try {
      await _repository.flagReview(reviewId, reason);
      // Refresh the reviews list
      await loadReviews(options: state.currentOptions, refresh: true);
    } catch (e) {
      state = state.copyWith(error: 'Failed to flag review: $e');
    }
  }

  Future<void> deleteReview(String reviewId) async {
    try {
      await _repository.deleteReview(reviewId);
      // Refresh the reviews list
      await loadReviews(options: state.currentOptions, refresh: true);
    } catch (e) {
      state = state.copyWith(error: 'Failed to delete review: $e');
    }
  }
}

// Providers
final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  return ReviewRepository();
});

final reviewProvider = StateNotifierProvider<ReviewNotifier, ReviewState>((
  ref,
) {
  final repository = ref.watch(reviewRepositoryProvider);
  return ReviewNotifier(repository);
});

// Stream providers for real-time updates
final providerReviewsStreamProvider =
    StreamProvider.family<List<Review>, String>((ref, providerId) {
      final repository = ref.watch(reviewRepositoryProvider);
      return repository.watchProviderReviews(providerId);
    });

final reviewStatsStreamProvider = StreamProvider.family<ReviewStats, String>((
  ref,
  providerId,
) {
  final repository = ref.watch(reviewRepositoryProvider);
  return repository.watchReviewStats(providerId);
});
