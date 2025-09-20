import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/availability_schedule.dart';
import '../models/availability_model.dart';

class AvailabilityRepository {
  Future<Availability?> fetchAvailability(String providerId) async {
    final docRef = _firestore
        .collection('providers')
        .doc(providerId)
        .collection('availability')
        .doc('schedule');
    final doc = await docRef.get();
    if (!doc.exists || doc.data() == null) return null;
    return Availability.fromJson({...doc.data()!, 'providerId': providerId});
  }

  Future<void> updateAvailability(Availability availability) async {
    final docRef = _firestore
        .collection('providers')
        .doc(availability.providerId)
        .collection('availability')
        .doc('schedule');
    await docRef.set(availability.toJson());
  }

  Stream<Availability> subscribeAvailability(String providerId) {
    return _firestore
        .collection('providers')
        .doc(providerId)
        .collection('availability')
        .doc('schedule')
        .snapshots()
        .map((doc) {
          if (!doc.exists || doc.data() == null) {
            throw Exception('No availability found');
          }
          return Availability.fromJson({
            ...doc.data()!,
            'providerId': providerId,
          });
        });
  }

  Future<void> bookTimeSlot(
    String providerId,
    TimeSlot slot,
    String bookingId,
  ) async {
    final docRef = _firestore
        .collection('providers')
        .doc(providerId)
        .collection('availability')
        .doc('schedule');
    final doc = await docRef.get();
    if (!doc.exists || doc.data() == null) return;
    var schedule = AvailabilitySchedule.fromJson({
      ...doc.data()!,
      'providerId': providerId,
    });
    final updatedSlots = schedule.slots.map((s) {
      if (s.start == slot.start && s.end == slot.end) {
        return s.copyWith(isAvailable: false, bookingId: bookingId);
      }
      return s;
    }).toList();
    schedule = schedule.copyWith(slots: updatedSlots);
    await docRef.set(schedule.toJson());
  }

  Stream<AvailabilitySchedule?> getProviderSchedule(String providerId) {
    return _firestore
        .collection('providers')
        .doc(providerId)
        .collection('availability')
        .doc('schedule')
        .snapshots()
        .map((doc) {
          if (!doc.exists || doc.data() == null) return null;
          return AvailabilitySchedule.fromJson({
            ...doc.data()!,
            'providerId': providerId,
          });
        });
  }

  Future<void> addTimeSlot(String providerId, TimeSlot slot) async {
    final docRef = _firestore
        .collection('providers')
        .doc(providerId)
        .collection('availability')
        .doc('schedule');
    final doc = await docRef.get();
    AvailabilitySchedule schedule;
    if (doc.exists && doc.data() != null) {
      schedule = AvailabilitySchedule.fromJson({
        ...doc.data()!,
        'providerId': providerId,
      });
      schedule = schedule.copyWith(slots: [...schedule.slots, slot]);
    } else {
      final now = DateTime.now();
      schedule = AvailabilitySchedule(
        providerId: providerId,
        slots: [slot],
        validFrom: now,
        validUntil: now.add(const Duration(days: 365)),
      );
    }
    await docRef.set(schedule.toJson());
  }

  Future<void> updateTimeSlot(
    String providerId,
    TimeSlot oldSlot,
    TimeSlot newSlot,
  ) async {
    final docRef = _firestore
        .collection('providers')
        .doc(providerId)
        .collection('availability')
        .doc('schedule');
    final doc = await docRef.get();
    if (!doc.exists || doc.data() == null) return;
    var schedule = AvailabilitySchedule.fromJson({
      ...doc.data()!,
      'providerId': providerId,
    });
    final updatedSlots = schedule.slots.map((slot) {
      if (slot.start == oldSlot.start && slot.end == oldSlot.end) {
        return newSlot;
      }
      return slot;
    }).toList();
    schedule = schedule.copyWith(slots: updatedSlots);
    await docRef.set(schedule.toJson());
  }

  Future<void> removeTimeSlot(String providerId, TimeSlot slot) async {
    final docRef = _firestore
        .collection('providers')
        .doc(providerId)
        .collection('availability')
        .doc('schedule');
    final doc = await docRef.get();
    if (!doc.exists || doc.data() == null) return;
    var schedule = AvailabilitySchedule.fromJson({
      ...doc.data()!,
      'providerId': providerId,
    });
    final updatedSlots = schedule.slots
        .where((s) => !(s.start == slot.start && s.end == slot.end))
        .toList();
    schedule = schedule.copyWith(slots: updatedSlots);
    await docRef.set(schedule.toJson());
  }

  final FirebaseFirestore _firestore;

  AvailabilityRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;
}
