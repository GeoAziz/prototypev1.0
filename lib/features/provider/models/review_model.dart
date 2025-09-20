import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String id;
  final String providerId;
  final String userId;
  final String userName;
  final String userAvatar;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final Map<String, dynamic>? media;
  final List<String> helpfulUserIds;
  final bool isVerifiedBooking;
  final ReviewStatus status;
  final Map<String, dynamic>? response;

  const Review({
    required this.id,
    required this.providerId,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.media,
    this.helpfulUserIds = const [],
    this.isVerifiedBooking = false,
    this.status = ReviewStatus.published,
    this.response,
  });

  Review copyWith({
    String? id,
    String? providerId,
    String? userId,
    String? userName,
    String? userAvatar,
    double? rating,
    String? comment,
    DateTime? createdAt,
    Map<String, dynamic>? media,
    List<String>? helpfulUserIds,
    bool? isVerifiedBooking,
    ReviewStatus? status,
    Map<String, dynamic>? response,
  }) {
    return Review(
      id: id ?? this.id,
      providerId: providerId ?? this.providerId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      media: media ?? this.media,
      helpfulUserIds: helpfulUserIds ?? this.helpfulUserIds,
      isVerifiedBooking: isVerifiedBooking ?? this.isVerifiedBooking,
      status: status ?? this.status,
      response: response ?? this.response,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'providerId': providerId,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'rating': rating,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
      'media': media,
      'helpfulUserIds': helpfulUserIds,
      'isVerifiedBooking': isVerifiedBooking,
      'status': status.name,
      'response': response,
    };
  }

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as String,
      providerId: json['providerId'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userAvatar: json['userAvatar'] as String,
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'] as String,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      media: json['media'] as Map<String, dynamic>?,
      helpfulUserIds: List<String>.from(json['helpfulUserIds'] ?? []),
      isVerifiedBooking: json['isVerifiedBooking'] as bool? ?? false,
      status: ReviewStatus.values.firstWhere(
        (e) =>
            e.name ==
            (json['status'] as String? ?? ReviewStatus.published.name),
      ),
      response: json['response'] as Map<String, dynamic>?,
    );
  }

  bool get hasResponse => response != null;
  bool get isHelpful => helpfulUserIds.isNotEmpty;
  int get helpfulCount => helpfulUserIds.length;
  bool isHelpfulToUser(String userId) => helpfulUserIds.contains(userId);
}

enum ReviewStatus { pending, published, flagged, removed }

class ReviewQueryOptions {
  final String? providerId;
  final String? userId;
  final double? minRating;
  final double? maxRating;
  final bool? hasResponse;
  final bool? isVerifiedOnly;
  final ReviewSortOption sortBy;
  final bool descending;
  final int limit;
  final DocumentSnapshot? startAfter;

  const ReviewQueryOptions({
    this.providerId,
    this.userId,
    this.minRating,
    this.maxRating,
    this.hasResponse,
    this.isVerifiedOnly,
    this.sortBy = ReviewSortOption.date,
    this.descending = true,
    this.limit = 10,
    this.startAfter,
  });

  ReviewQueryOptions copyWith({
    String? providerId,
    String? userId,
    double? minRating,
    double? maxRating,
    bool? hasResponse,
    bool? isVerifiedOnly,
    ReviewSortOption? sortBy,
    bool? descending,
    int? limit,
    DocumentSnapshot? startAfter,
  }) {
    return ReviewQueryOptions(
      providerId: providerId ?? this.providerId,
      userId: userId ?? this.userId,
      minRating: minRating ?? this.minRating,
      maxRating: maxRating ?? this.maxRating,
      hasResponse: hasResponse ?? this.hasResponse,
      isVerifiedOnly: isVerifiedOnly ?? this.isVerifiedOnly,
      sortBy: sortBy ?? this.sortBy,
      descending: descending ?? this.descending,
      limit: limit ?? this.limit,
      startAfter: startAfter ?? this.startAfter,
    );
  }
}

enum ReviewSortOption { date, rating, helpfulCount }

class ReviewStats {
  final double averageRating;
  final int totalReviews;
  final Map<int, int> ratingDistribution;
  final int helpfulCount;
  final int verifiedCount;
  final int responseCount;

  const ReviewStats({
    required this.averageRating,
    required this.totalReviews,
    required this.ratingDistribution,
    required this.helpfulCount,
    required this.verifiedCount,
    required this.responseCount,
  });

  factory ReviewStats.fromJson(Map<String, dynamic> json) {
    return ReviewStats(
      averageRating: (json['averageRating'] as num).toDouble(),
      totalReviews: json['totalReviews'] as int,
      ratingDistribution: Map<int, int>.from(
        (json['ratingDistribution'] as Map).map(
          (key, value) => MapEntry(int.parse(key as String), value as int),
        ),
      ),
      helpfulCount: json['helpfulCount'] as int,
      verifiedCount: json['verifiedCount'] as int,
      responseCount: json['responseCount'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'averageRating': averageRating,
      'totalReviews': totalReviews,
      'ratingDistribution': ratingDistribution.map(
        (key, value) => MapEntry(key.toString(), value),
      ),
      'helpfulCount': helpfulCount,
      'verifiedCount': verifiedCount,
      'responseCount': responseCount,
    };
  }

  double getPercentageForRating(int rating) {
    if (totalReviews == 0) return 0.0;
    return (ratingDistribution[rating] ?? 0) / totalReviews * 100;
  }
}
