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
      bookedAt: DateTime.parse(json['bookedAt'] as String),
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
      'bookedAt': bookedAt.toIso8601String(),
      'userId': userId,
      'amount': amount,
    };
  }

  Map<String, dynamic> toSqlite() {
    return {
      'id': id,
      'serviceTitle': serviceTitle,
      'provider': provider,
      'status': status,
      'bookedAt': bookedAt.toIso8601String(),
      'userId': userId,
      'amount': amount,
    };
  }

  factory Booking.fromSqlite(Map<String, dynamic> data) {
    return Booking(
      id: data['id'] as String,
      serviceTitle: data['serviceTitle'] as String,
      provider: data['provider'] as String,
      status: data['status'] as String,
      bookedAt: DateTime.parse(data['bookedAt'] as String),
      userId: data['userId'] as String,
      amount: data['amount'] as double,
    );
  }
}
