import 'package:json_annotation/json_annotation.dart';

part 'booking.g.dart';

@JsonSerializable()
class Booking {
  final String id;
  final String providerId;
  final String userId;
  final DateTime bookingTime;
  final String serviceId;
  final double price;
  final String status;
  final Map<String, dynamic>? metadata;

  Booking({
    required this.id,
    required this.providerId,
    required this.userId,
    required this.bookingTime,
    required this.serviceId,
    required this.price,
    this.status = 'pending',
    this.metadata,
  });

  factory Booking.fromJson(Map<String, dynamic> json) =>
      _$BookingFromJson(json);

  Map<String, dynamic> toJson() => _$BookingToJson(this);
}
