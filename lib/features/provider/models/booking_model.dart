class Booking {
  final String id;
  final String providerId;
  final String userId;
  final DateTime date;
  final String status;
  final double price;

  Booking({
    required this.id,
    required this.providerId,
    required this.userId,
    required this.date,
    required this.status,
    required this.price,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'providerId': providerId,
    'userId': userId,
    'date': date.toIso8601String(),
    'status': status,
    'price': price,
  };

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
    id: json['id'],
    providerId: json['providerId'],
    userId: json['userId'],
    date: DateTime.parse(json['date']),
    status: json['status'],
    price: (json['price'] ?? 0.0).toDouble(),
  );
}
