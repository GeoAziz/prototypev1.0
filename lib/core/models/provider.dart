import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/enums/user_role.dart';
import '../../../core/enums/service_category.dart';

class Provider {
  final String id;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final String businessName;
  final String businessAddress;
  final String businessDescription;
  final String? profileImageUrl;
  final List<ServiceCategory> serviceCategories;
  final int serviceArea;
  final List<String> serviceImages;
  final double rating;
  final int totalRatings;
  final DateTime createdAt;
  final DateTime updatedAt;
  final GeoPoint? location;
  final bool isActive;

  // Additional computed properties
  final double? distance; // Distance from user in km
  final double averagePrice; // Average service price
  final List<String> serviceAreas; // Service area names
  final bool isAvailable; // Current availability status
  final int reviewCount; // Number of reviews
  final String profileImage; // Profile image URL

  Provider({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.businessName,
    required this.businessAddress,
    required this.businessDescription,
    required this.profileImageUrl,
    required this.serviceCategories,
    required this.serviceArea,
    required this.serviceImages,
    required this.rating,
    required this.totalRatings,
    required this.createdAt,
    required this.updatedAt,
    this.location,
    this.isActive = true,
    this.distance,
    this.averagePrice = 0.0,
    this.serviceAreas = const [],
    this.isAvailable = true,
    this.reviewCount = 0,
    this.profileImage = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role.toString(),
      'businessName': businessName,
      'businessAddress': businessAddress,
      'businessDescription': businessDescription,
      'profileImageUrl': profileImageUrl,
      'serviceCategories': serviceCategories.map((e) => e.toString()).toList(),
      'serviceArea': serviceArea,
      'serviceImages': serviceImages,
      'rating': rating,
      'totalRatings': totalRatings,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'location': location,
      'isActive': isActive,
    };
  }

  factory Provider.fromJson(Map<String, dynamic> json) {
    return Provider(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      role: json['role'] != null
          ? UserRole.values.firstWhere(
              (e) => e.toString() == json['role'],
              orElse: () => UserRole.provider,
            )
          : UserRole.provider,
      businessName: json['businessName'] as String? ?? '',
      businessAddress: json['businessAddress'] as String? ?? '',
      businessDescription: json['businessDescription'] as String? ?? '',
      profileImageUrl: json['profileImageUrl'] as String?,
      serviceCategories: (json['serviceCategories'] as List<dynamic>? ?? [])
          .map(
            (e) => ServiceCategory.values.firstWhere(
              (cat) => cat.toString() == e,
              orElse: () => ServiceCategory.other,
            ),
          )
          .toList(),
      serviceArea: json['serviceArea'] as int? ?? 0,
      serviceImages: (json['serviceImages'] as List<dynamic>? ?? [])
          .map((e) => e as String)
          .toList(),
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      totalRatings: json['totalRatings'] as int? ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      location: json['location'] is GeoPoint
          ? json['location'] as GeoPoint
          : null,
      isActive: json['isActive'] as bool? ?? true,
      distance: json['distance'] as double?,
      averagePrice: (json['averagePrice'] as num?)?.toDouble() ?? 100.0,
      serviceAreas: (json['serviceAreas'] as List<dynamic>? ?? [])
          .map((e) => e as String)
          .toList(),
      isAvailable: json['isAvailable'] as bool? ?? true,
      reviewCount:
          json['reviewCount'] as int? ?? json['totalRatings'] as int? ?? 0,
      profileImage:
          json['profileImage'] as String? ??
          json['profileImageUrl'] as String? ??
          '',
    );
  }
}
