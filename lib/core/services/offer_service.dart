import 'package:cloud_firestore/cloud_firestore.dart';

class OfferService {
  final FirebaseFirestore firestore;
  OfferService({FirebaseFirestore? firestore})
    : firestore = firestore ?? FirebaseFirestore.instance;

  Stream<List<Map<String, dynamic>>> streamOffers() {
    return firestore
        .collection('offers')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList(),
        );
  }
}
