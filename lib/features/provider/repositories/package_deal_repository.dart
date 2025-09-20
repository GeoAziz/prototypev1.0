import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/package_deal.dart';

class PackageDealRepository {
  final FirebaseFirestore _firestore;

  PackageDealRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<PackageDeal>> fetchPackageDeals(String providerId) async {
    try {
      final snapshot = await _firestore
          .collection('providers')
          .doc(providerId)
          .collection('package_deals')
          .get();

      return snapshot.docs
          .map((doc) => PackageDeal.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Error fetching package deals: $e');
    }
  }

  Future<void> createPackageDeal(PackageDeal packageDeal) async {
    try {
      await _firestore
          .collection('providers')
          .doc(packageDeal.providerId)
          .collection('package_deals')
          .doc(packageDeal.id)
          .set(packageDeal.toJson());
    } catch (e) {
      throw Exception('Error creating package deal: $e');
    }
  }

  Future<void> updatePackageDeal(PackageDeal packageDeal) async {
    try {
      await _firestore
          .collection('providers')
          .doc(packageDeal.providerId)
          .collection('package_deals')
          .doc(packageDeal.id)
          .update(packageDeal.toJson());
    } catch (e) {
      throw Exception('Error updating package deal: $e');
    }
  }

  Future<void> deletePackageDeal(String packageId) async {
    try {
      // First get the package to get the providerId
      final snapshot = await _firestore
          .collectionGroup('package_deals')
          .where('id', isEqualTo: packageId)
          .get();

      if (snapshot.docs.isEmpty) {
        throw Exception('Package deal not found');
      }

      final packageDeal = PackageDeal.fromJson({
        ...snapshot.docs[0].data(),
        'id': packageId,
      });

      await _firestore
          .collection('providers')
          .doc(packageDeal.providerId)
          .collection('package_deals')
          .doc(packageId)
          .delete();
    } catch (e) {
      throw Exception('Error deleting package deal: $e');
    }
  }
}
