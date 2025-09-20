import 'package:cloud_firestore/cloud_firestore.dart';

class ProviderRegistrationModel {
  final String uid;
  final String fullName;
  final String email;
  final String phone;
  final String? businessName;
  final GeoPoint? location;
  final List<String> serviceCategories;
  final String serviceArea;
  final int yearsOfExperience;
  final List<String> portfolioUrls;
  final Map<String, dynamic>? bankDetails;
  final Map<String, List<String>>? availability;
  final List<String>? verificationDocUrls;
  final String? bio;
  final String? profilePhotoUrl;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime? lastUpdated;

  ProviderRegistrationModel({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.phone,
    this.businessName,
    this.location,
    this.serviceCategories = const [],
    this.serviceArea = '',
    this.yearsOfExperience = 0,
    this.portfolioUrls = const [],
    this.bankDetails,
    this.availability,
    this.verificationDocUrls,
    this.bio,
    this.profilePhotoUrl,
    this.isVerified = false,
    DateTime? createdAt,
    this.lastUpdated,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'businessName': businessName,
      'location': location,
      'serviceCategories': serviceCategories,
      'serviceArea': serviceArea,
      'yearsOfExperience': yearsOfExperience,
      'portfolioUrls': portfolioUrls,
      'bankDetails': bankDetails,
      'availability': availability,
      'verificationDocUrls': verificationDocUrls,
      'bio': bio,
      'profilePhotoUrl': profilePhotoUrl,
      'isVerified': isVerified,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastUpdated': lastUpdated != null
          ? Timestamp.fromDate(lastUpdated!)
          : null,
      'role': 'provider',
    };
  }

  factory ProviderRegistrationModel.fromMap(Map<String, dynamic> map) {
    return ProviderRegistrationModel(
      uid: map['uid'] as String,
      fullName: map['fullName'] as String,
      email: map['email'] as String,
      phone: map['phone'] as String,
      businessName: map['businessName'] as String?,
      serviceCategories: List<String>.from(map['serviceCategories'] ?? []),
      serviceArea: map['serviceArea'] as String? ?? '',
      yearsOfExperience: map['yearsOfExperience'] as int? ?? 0,
      portfolioUrls: List<String>.from(map['portfolioUrls'] ?? []),
      bankDetails: map['bankDetails'] as Map<String, dynamic>?,
      availability: (map['availability'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(key, List<String>.from(value)),
      ),
      verificationDocUrls: List<String>.from(map['verificationDocUrls'] ?? []),
      bio: map['bio'] as String?,
      profilePhotoUrl: map['profilePhotoUrl'] as String?,
      isVerified: map['isVerified'] as bool? ?? false,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      lastUpdated: (map['lastUpdated'] as Timestamp?)?.toDate(),
    );
  }

  ProviderRegistrationModel copyWith({
    String? uid,
    String? fullName,
    String? email,
    String? phone,
    String? businessName,
    List<String>? serviceCategories,
    String? serviceArea,
    int? yearsOfExperience,
    List<String>? portfolioUrls,
    Map<String, dynamic>? bankDetails,
    Map<String, List<String>>? availability,
    List<String>? verificationDocUrls,
    String? bio,
    String? profilePhotoUrl,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? lastUpdated,
  }) {
    return ProviderRegistrationModel(
      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      businessName: businessName ?? this.businessName,
      serviceCategories: serviceCategories ?? this.serviceCategories,
      serviceArea: serviceArea ?? this.serviceArea,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      portfolioUrls: portfolioUrls ?? this.portfolioUrls,
      bankDetails: bankDetails ?? this.bankDetails,
      availability: availability ?? this.availability,
      verificationDocUrls: verificationDocUrls ?? this.verificationDocUrls,
      bio: bio ?? this.bio,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      lastUpdated: lastUpdated ?? DateTime.now(),
    );
  }
}
