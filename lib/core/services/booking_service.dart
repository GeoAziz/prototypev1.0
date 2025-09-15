import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:poafix/core/models/booking.dart';

class BookingService {
  final FirebaseFirestore firestore;
  late final CollectionReference _bookingsCollection;

  BookingService({FirebaseFirestore? firestore})
    : firestore = firestore ?? FirebaseFirestore.instance {
    _bookingsCollection = this.firestore.collection('bookings');
  }

  Future<DocumentReference> addBooking(Map<String, dynamic> bookingData) async {
    return await _bookingsCollection.add(bookingData);
  }

  Stream<List<Booking>> streamBookingsForUser(String userId) {
    return firestore
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .orderBy('bookedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Booking.fromJson(doc.data(), doc.id))
              .toList(),
        );
  }
}
