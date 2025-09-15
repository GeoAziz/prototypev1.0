import 'package:cloud_firestore/cloud_firestore.dart';

class QuickService {
  final String id;
  final String title;
  final String wait;
  final String price;
  final String location;
  final String provider;
  final String serviceType;
  final String status;
  final DateTime availableUntil;

  QuickService({
    required this.id,
    required this.title,
    required this.wait,
    required this.price,
    required this.location,
    required this.provider,
    required this.serviceType,
    required this.status,
    required this.availableUntil,
  });

  factory QuickService.fromJson(Map<String, dynamic> json) {
    return QuickService(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      wait: json['wait'] ?? '',
      price: json['price'] ?? '',
      location: json['location'] ?? '',
      provider: json['provider'] ?? '',
      serviceType: json['serviceType'] ?? '',
      status: json['status'] ?? 'available',
      availableUntil: (json['availableUntil'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'wait': wait,
      'price': price,
      'location': location,
      'provider': provider,
      'serviceType': serviceType,
      'status': status,
      'availableUntil': Timestamp.fromDate(availableUntil),
    };
  }
}
