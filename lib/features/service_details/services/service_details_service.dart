import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:poafix/core/models/service.dart';
import 'package:poafix/core/models/review.dart';
import 'package:poafix/core/services/firebase_service.dart';

class ServiceDetailsService {
  final _firestore = FirebaseFirestore.instance;
  final _firebaseService = FirebaseService();

  // Fetch service details
  Stream<Service?> streamService(String serviceId) {
    return _firestore.collection('services').doc(serviceId).snapshots().map((
      doc,
    ) {
      if (!doc.exists) return null;
      final data = doc.data()!;
      data['id'] = doc.id;
      return Service.fromJson(data);
    });
  }

  // Fetch reviews with pagination
  Future<QuerySnapshot> getReviews(
    String serviceId, {
    DocumentSnapshot? lastDoc,
  }) {
    var query = _firestore
        .collection('reviews')
        .where('serviceId', isEqualTo: serviceId)
        .orderBy('createdAt', descending: true)
        .limit(5);

    if (lastDoc != null) {
      query = query.startAfterDocument(lastDoc);
    }

    return query.get();
  }

  // Toggle favorite status
  Future<void> toggleFavorite(String serviceId, String userId) async {
    final docRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(serviceId);

    final doc = await docRef.get();
    if (doc.exists) {
      await docRef.delete();
    } else {
      await docRef.set({
        'serviceId': serviceId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // Check if service is favorited
  Stream<bool> isFavorited(String serviceId, String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(serviceId)
        .snapshots()
        .map((doc) => doc.exists);
  }
}
