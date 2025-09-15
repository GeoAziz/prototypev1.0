import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String id;
  final String serviceId;
  final String userId;
  final String userName;
  final String userImage;
  final double rating;
  final String comment;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.serviceId,
    required this.userId,
    required this.userName,
    required this.userImage,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] ?? '',
      serviceId: json['serviceId'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      userImage: json['userImage'] ?? '',
      rating: (json['rating'] is num)
          ? (json['rating'] as num).toDouble()
          : double.tryParse(json['rating']?.toString() ?? '') ?? 0.0,
      comment: json['comment'] ?? '',
      createdAt: json['createdAt'] is String
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : (json['createdAt'] is Timestamp
                ? (json['createdAt'] as Timestamp).toDate()
                : DateTime.now()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serviceId': serviceId,
      'userId': userId,
      'userName': userName,
      'userImage': userImage,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

// Example reviews for demo
List<Review> demoReviews = [
  Review(
    id: '1',
    serviceId: '1',
    userId: 'user1',
    userName: 'Sarah Johnson',
    userImage: 'assets/images/user1.jpg',
    rating: 5.0,
    comment:
        'Excellent service! They did a thorough job cleaning our apartment and were very professional. Will definitely book again.',
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
  ),
  Review(
    id: '2',
    serviceId: '1',
    userId: 'user2',
    userName: 'Michael Brown',
    userImage: 'assets/images/user2.jpg',
    rating: 4.5,
    comment:
        'Great cleaning service. They arrived on time and did a fantastic job. Just missed a few spots under the furniture.',
    createdAt: DateTime.now().subtract(const Duration(days: 5)),
  ),
  Review(
    id: '3',
    serviceId: '1',
    userId: 'user3',
    userName: 'Emily Davis',
    userImage: 'assets/images/user3.jpg',
    rating: 5.0,
    comment:
        'I\'m very impressed with the cleaning service. My home hasn\'t been this clean in years! The staff was friendly and efficient.',
    createdAt: DateTime.now().subtract(const Duration(days: 10)),
  ),
  Review(
    id: '4',
    serviceId: '2',
    userId: 'user4',
    userName: 'James Wilson',
    userImage: 'assets/images/user4.jpg',
    rating: 5.0,
    comment:
        'The deep cleaning service was worth every penny. They cleaned areas I didn\'t even think about. My house feels brand new!',
    createdAt: DateTime.now().subtract(const Duration(days: 7)),
  ),
  Review(
    id: '5',
    serviceId: '3',
    userId: 'user5',
    userName: 'Alex Thompson',
    userImage: 'assets/images/user5.jpg',
    rating: 4.7,
    comment:
        'Quick response to my emergency leak. Fixed the problem efficiently and gave me advice on preventing future issues.',
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
  ),
];
