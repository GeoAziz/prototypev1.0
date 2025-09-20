import '../lib/core/enums/user_role.dart';
import '../lib/core/enums/service_category.dart';
import 'package:flutter_test/flutter_test.dart';
// import 'package:fresh_flutter_project/features/provider/models/provider_model.dart';
import '../lib/core/models/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  test('Provider model serialization', () {
    final provider = Provider(
      id: 'p1',
      name: 'Test Provider',
      email: 'test@example.com',
      phone: '1234567890',
      role: UserRole.provider,
      businessName: 'Test Business',
      businessAddress: '123 Main St',
      businessDescription: 'A test business',
      profileImageUrl: 'url',
      serviceCategories: [ServiceCategory.plumbing],
      serviceArea: 1,
      serviceImages: ['img1.jpg'],
      rating: 4.5,
      totalRatings: 10,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      location: const GeoPoint(0, 0),
      isActive: true,
    );
    final json = provider.toJson();
    final fromJson = Provider.fromJson(json);
    expect(fromJson.id, provider.id);
    expect(fromJson.name, provider.name);
  });
}
