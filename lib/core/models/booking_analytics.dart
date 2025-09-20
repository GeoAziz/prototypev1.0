import 'package:cloud_firestore/cloud_firestore.dart';

class BookingAnalytics {
  final String providerId;
  final DateTime date;
  final int totalBookings;
  final double totalEarnings;
  final double avgRating;
  final int completedBookings;
  final int cancelledBookings;

  BookingAnalytics({
    required this.providerId,
    required this.date,
    required this.totalBookings,
    required this.totalEarnings,
    required this.avgRating,
    required this.completedBookings,
    required this.cancelledBookings,
  });

  factory BookingAnalytics.fromJson(Map<String, dynamic> json) {
    return BookingAnalytics(
      providerId: json['providerId'] as String,
      date: (json['date'] as Timestamp).toDate(),
      totalBookings: json['totalBookings'] as int,
      totalEarnings: (json['totalEarnings'] as num).toDouble(),
      avgRating: (json['avgRating'] as num).toDouble(),
      completedBookings: json['completedBookings'] as int,
      cancelledBookings: json['cancelledBookings'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'providerId': providerId,
      'date': Timestamp.fromDate(date),
      'totalBookings': totalBookings,
      'totalEarnings': totalEarnings,
      'avgRating': avgRating,
      'completedBookings': completedBookings,
      'cancelledBookings': cancelledBookings,
    };
  }
}
