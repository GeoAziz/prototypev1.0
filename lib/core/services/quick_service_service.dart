import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:poafix/core/models/quick_service.dart';
import 'package:poafix/core/services/base_service.dart';

class QuickServiceService extends BaseService {
  QuickServiceService({super.firestore});

  Stream<List<QuickService>> streamQuickServices() {
    return handleServiceStream(
      firestore
          .collection('quick_services')
          .where('status', isEqualTo: 'available')
          .where(
            'availableUntil',
            isGreaterThan: Timestamp.fromDate(DateTime.now()),
          )
          .orderBy('availableUntil')
          .snapshots()
          .map(
            (snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return QuickService.fromJson(data);
            }).toList(),
          ),
    );
  }

  Future<void> bookQuickService(String quickServiceId) {
    return handleServiceCall(() async {
      await firestore.collection('quick_services').doc(quickServiceId).update({
        'status': 'booked',
        'bookedAt': Timestamp.now(),
      });
    });
  }
}
