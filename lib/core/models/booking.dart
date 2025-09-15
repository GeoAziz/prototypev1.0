import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  final String id;
  final String serviceTitle;
  final String provider;
  final String status;
  final DateTime bookedAt;
  final String userId;
  final double amount;

  Booking({
    required this.id,
    required this.serviceTitle,
    required this.provider,
    required this.status,
    required this.bookedAt,
    required this.userId,
    required this.amount,
  });

  factory Booking.fromJson(Map<String, dynamic> json, String id) {
    return Booking(
      id: id,
      serviceTitle: json['serviceTitle'] ?? '',
      provider: json['provider'] ?? '',
      status: json['status'] ?? 'pending',
      bookedAt: (json['bookedAt'] as Timestamp).toDate(),
      userId: json['userId'] ?? '',
      amount: (json['amount'] is int)
          ? (json['amount'] as int).toDouble()
          : (json['amount'] is double)
              ? json['amount'] as double
              : double.tryParse(json['amount']?.toString() ?? '') ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'serviceTitle': serviceTitle,
      'provider': provider,
      'status': status,
      'bookedAt': Timestamp.fromDate(bookedAt),
      'userId': userId,
      'amount': amount,
    };
  }
}
