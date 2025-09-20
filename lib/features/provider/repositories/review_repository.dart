import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review_model.dart';

class ReviewRepository {
  final FirebaseFirestore _firestore;
  final String _collection = 'reviews';
  final String _statsCollection = 'review_stats';

  ReviewRepository([FirebaseFirestore? firestore])
    : _firestore = firestore ?? FirebaseFirestore.instance;

  // Create a new review
  Future<Review> createReview({
    required String providerId,
    required String userId,
    required String userName,
    required String userAvatar,
    required double rating,
    required String comment,
    Map<String, dynamic>? media,
    bool isVerifiedBooking = false,
  }) async {
    final docRef = _firestore.collection(_collection).doc();
    final now = DateTime.now();

    final review = Review(
      id: docRef.id,
      providerId: providerId,
      userId: userId,
      userName: userName,
      userAvatar: userAvatar,
      rating: rating,
      comment: comment,
      createdAt: now,
      media: media,
      isVerifiedBooking: isVerifiedBooking,
    );

    await docRef.set(review.toJson());
    await _updateReviewStats(providerId);

    return review;
  }

  // Get paginated reviews with filtering options
  Future<QuerySnapshot<Map<String, dynamic>>> getReviews(
    ReviewQueryOptions options,
  ) async {
    Query<Map<String, dynamic>> query = _firestore.collection(_collection);

    // Apply filters
    if (options.providerId != null) {
      query = query.where('providerId', isEqualTo: options.providerId);
    }
    if (options.userId != null) {
      query = query.where('userId', isEqualTo: options.userId);
    }
    if (options.minRating != null) {
      query = query.where('rating', isGreaterThanOrEqualTo: options.minRating);
    }
    if (options.maxRating != null) {
      query = query.where('rating', isLessThanOrEqualTo: options.maxRating);
    }
    if (options.hasResponse != null) {
      query = query.where('hasResponse', isEqualTo: options.hasResponse);
    }
    if (options.isVerifiedOnly == true) {
      query = query.where('isVerifiedBooking', isEqualTo: true);
    }

    // Apply sorting
    switch (options.sortBy) {
      case ReviewSortOption.date:
        query = query.orderBy('createdAt', descending: options.descending);
        break;
      case ReviewSortOption.rating:
        query = query.orderBy('rating', descending: options.descending);
        break;
      case ReviewSortOption.helpfulCount:
        query = query.orderBy('helpfulCount', descending: options.descending);
        break;
    }

    // Apply pagination
    if (options.startAfter != null) {
      query = query.startAfterDocument(options.startAfter!);
    }
    query = query.limit(options.limit);

    return query.get();
  }

  // Get review statistics for a provider
  Future<ReviewStats> getReviewStats(String providerId) async {
    final doc = await _firestore
        .collection(_statsCollection)
        .doc(providerId)
        .get();

    if (!doc.exists) {
      // Return default stats if none exist
      return ReviewStats(
        averageRating: 0,
        totalReviews: 0,
        ratingDistribution: {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
        helpfulCount: 0,
        verifiedCount: 0,
        responseCount: 0,
      );
    }

    return ReviewStats.fromJson(doc.data()!);
  }

  // Update review statistics
  Future<void> _updateReviewStats(String providerId) async {
    final reviews = await _firestore
        .collection(_collection)
        .where('providerId', isEqualTo: providerId)
        .where('status', isEqualTo: ReviewStatus.published.name)
        .get();

    if (reviews.docs.isEmpty) return;

    var totalRating = 0.0;
    final ratingDist = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    var helpfulCount = 0;
    var verifiedCount = 0;
    var responseCount = 0;

    for (final doc in reviews.docs) {
      final review = Review.fromJson(doc.data());
      totalRating += review.rating;
      ratingDist[review.rating.round()] =
          (ratingDist[review.rating.round()] ?? 0) + 1;
      helpfulCount += review.helpfulCount;
      if (review.isVerifiedBooking) verifiedCount++;
      if (review.hasResponse) responseCount++;
    }

    final stats = ReviewStats(
      averageRating: totalRating / reviews.docs.length,
      totalReviews: reviews.docs.length,
      ratingDistribution: ratingDist,
      helpfulCount: helpfulCount,
      verifiedCount: verifiedCount,
      responseCount: responseCount,
    );

    await _firestore
        .collection(_statsCollection)
        .doc(providerId)
        .set(stats.toJson());
  }

  // Mark a review as helpful
  Future<void> markReviewHelpful(String reviewId, String userId) async {
    await _firestore.collection(_collection).doc(reviewId).update({
      'helpfulUserIds': FieldValue.arrayUnion([userId]),
    });
  }

  // Remove helpful mark from a review
  Future<void> unmarkReviewHelpful(String reviewId, String userId) async {
    await _firestore.collection(_collection).doc(reviewId).update({
      'helpfulUserIds': FieldValue.arrayRemove([userId]),
    });
  }

  // Add provider response to a review
  Future<void> addResponse(
    String reviewId,
    Map<String, dynamic> response,
  ) async {
    await _firestore.collection(_collection).doc(reviewId).update({
      'response': response,
    });
  }

  // Flag a review for moderation
  Future<void> flagReview(String reviewId, String reason) async {
    await _firestore.collection(_collection).doc(reviewId).update({
      'status': ReviewStatus.flagged.name,
      'flagReason': reason,
    });
  }

  // Update review status (for moderation)
  Future<void> updateReviewStatus(String reviewId, ReviewStatus status) async {
    await _firestore.collection(_collection).doc(reviewId).update({
      'status': status.name,
    });
  }

  // Delete a review
  Future<void> deleteReview(String reviewId) async {
    final review = await _firestore.collection(_collection).doc(reviewId).get();
    if (!review.exists) return;

    final providerId = review.data()?['providerId'] as String;
    await review.reference.delete();
    await _updateReviewStats(providerId);
  }

  // Stream of review updates for a specific provider
  Stream<List<Review>> watchProviderReviews(String providerId) {
    return _firestore
        .collection(_collection)
        .where('providerId', isEqualTo: providerId)
        .where('status', isEqualTo: ReviewStatus.published.name)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Review.fromJson(doc.data())).toList(),
        );
  }

  // Stream of review statistics updates
  Stream<ReviewStats> watchReviewStats(String providerId) {
    return _firestore
        .collection(_statsCollection)
        .doc(providerId)
        .snapshots()
        .map(
          (snapshot) => snapshot.exists
              ? ReviewStats.fromJson(snapshot.data()!)
              : ReviewStats(
                  averageRating: 0,
                  totalReviews: 0,
                  ratingDistribution: {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
                  helpfulCount: 0,
                  verifiedCount: 0,
                  responseCount: 0,
                ),
        );
  }
}
