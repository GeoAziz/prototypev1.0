import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/specialization_model.dart';

class SpecializationRepository {
  final FirebaseFirestore _firestore;
  final String _collection = 'specializations';

  SpecializationRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<SpecializationModel>> getAllSpecializations() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      return snapshot.docs
          .map(
            (doc) =>
                SpecializationModel.fromJson({'id': doc.id, ...doc.data()}),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch specializations: $e');
    }
  }

  Future<List<SpecializationModel>> getSpecializationsByCategory(
    String category,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('category', isEqualTo: category)
          .get();

      return snapshot.docs
          .map(
            (doc) =>
                SpecializationModel.fromJson({'id': doc.id, ...doc.data()}),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch specializations by category: $e');
    }
  }

  Future<SpecializationModel?> getSpecialization(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (!doc.exists) return null;

      return SpecializationModel.fromJson({'id': doc.id, ...doc.data()!});
    } catch (e) {
      throw Exception('Failed to fetch specialization: $e');
    }
  }

  Future<void> addSpecialization(SpecializationModel specialization) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(specialization.id)
          .set(specialization.toJson());
    } catch (e) {
      throw Exception('Failed to add specialization: $e');
    }
  }

  Future<void> updateSpecialization(SpecializationModel specialization) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(specialization.id)
          .update(specialization.toJson());
    } catch (e) {
      throw Exception('Failed to update specialization: $e');
    }
  }

  Future<void> deleteSpecialization(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete specialization: $e');
    }
  }
}
