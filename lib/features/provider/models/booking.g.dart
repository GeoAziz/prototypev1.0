// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Booking _$BookingFromJson(Map<String, dynamic> json) => Booking(
  id: json['id'] as String,
  providerId: json['providerId'] as String,
  userId: json['userId'] as String,
  bookingTime: DateTime.parse(json['bookingTime'] as String),
  serviceId: json['serviceId'] as String,
  price: (json['price'] as num).toDouble(),
  status: json['status'] as String? ?? 'pending',
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$BookingToJson(Booking instance) => <String, dynamic>{
  'id': instance.id,
  'providerId': instance.providerId,
  'userId': instance.userId,
  'bookingTime': instance.bookingTime.toIso8601String(),
  'serviceId': instance.serviceId,
  'price': instance.price,
  'status': instance.status,
  'metadata': instance.metadata,
};
