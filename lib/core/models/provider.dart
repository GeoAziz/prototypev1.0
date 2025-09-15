import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceProvider {
  final String id;
  final String name;
  final String photo;
  final String bio;
  final String about;
  final double rating;
  final int reviewCount;
  final int projectsDone;
  final double completionRate;
  final int yearsOfExperience;
  final GeoPoint location;
  final double serviceRadius;
  final Map<String, String> workingHours;
  final List<String> serviceAreas;
  final Map<String, String> contactInfo;
  final bool isActive;

  ServiceProvider({
    required this.id,
    required this.name,
    required this.photo,
    required this.bio,
    required this.about,
    required this.rating,
    required this.reviewCount,
    required this.projectsDone,
    required this.completionRate,
    required this.yearsOfExperience,
    required this.location,
    required this.serviceRadius,
    required this.workingHours,
    required this.serviceAreas,
    required this.contactInfo,
    this.isActive = true,
  });

  factory ServiceProvider.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ServiceProvider(
      id: doc.id,
      name: data['name'] ?? '',
      photo: data['photo'] ?? '',
      bio: data['bio'] ?? '',
      about: data['about'] ?? '',
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: data['reviewCount'] ?? 0,
      projectsDone: data['projectsDone'] ?? 0,
      completionRate: (data['completionRate'] as num?)?.toDouble() ?? 0.0,
      yearsOfExperience: data['yearsOfExperience'] ?? 0,
      location: data['location'] as GeoPoint? ?? const GeoPoint(0, 0),
      serviceRadius: (data['serviceRadius'] as num?)?.toDouble() ?? 10.0,
      workingHours: Map<String, String>.from(data['workingHours'] ?? {}),
      serviceAreas: List<String>.from(data['serviceAreas'] ?? []),
      contactInfo: Map<String, String>.from(data['contactInfo'] ?? {}),
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'photo': photo,
      'bio': bio,
      'about': about,
      'rating': rating,
      'reviewCount': reviewCount,
      'projectsDone': projectsDone,
      'completionRate': completionRate,
      'yearsOfExperience': yearsOfExperience,
      'location': location,
      'serviceRadius': serviceRadius,
      'workingHours': workingHours,
      'serviceAreas': serviceAreas,
      'contactInfo': contactInfo,
      'isActive': isActive,
    };
  }
}
