import 'package:cloud_firestore/cloud_firestore.dart';

class TimeSlot {
  final DateTime start;
  final DateTime end;
  final bool isAvailable;
  final String? bookingId;
  final Map<String, dynamic>? metadata;

  const TimeSlot({
    required this.start,
    required this.end,
    this.isAvailable = true,
    this.bookingId,
    this.metadata,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      start: (json['start'] as Timestamp).toDate(),
      end: (json['end'] as Timestamp).toDate(),
      isAvailable: json['isAvailable'] as bool? ?? true,
      bookingId: json['bookingId'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'start': Timestamp.fromDate(start),
      'end': Timestamp.fromDate(end),
      'isAvailable': isAvailable,
      'bookingId': bookingId,
      'metadata': metadata,
    };
  }

  TimeSlot copyWith({
    DateTime? start,
    DateTime? end,
    bool? isAvailable,
    String? bookingId,
    Map<String, dynamic>? metadata,
  }) {
    return TimeSlot(
      start: start ?? this.start,
      end: end ?? this.end,
      isAvailable: isAvailable ?? this.isAvailable,
      bookingId: bookingId ?? this.bookingId,
      metadata: metadata ?? this.metadata,
    );
  }
}

class AvailabilitySchedule {
  final String providerId;
  final List<TimeSlot> slots;
  final DateTime validFrom;
  final DateTime validUntil;
  final Map<String, dynamic>? settings;

  const AvailabilitySchedule({
    required this.providerId,
    required this.slots,
    required this.validFrom,
    required this.validUntil,
    this.settings,
  });

  factory AvailabilitySchedule.fromJson(Map<String, dynamic> json) {
    return AvailabilitySchedule(
      providerId: json['providerId'] as String,
      slots: (json['slots'] as List<dynamic>)
          .map((e) => TimeSlot.fromJson(e as Map<String, dynamic>))
          .toList(),
      validFrom: (json['validFrom'] as Timestamp).toDate(),
      validUntil: (json['validUntil'] as Timestamp).toDate(),
      settings: json['settings'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'providerId': providerId,
      'slots': slots.map((e) => e.toJson()).toList(),
      'validFrom': Timestamp.fromDate(validFrom),
      'validUntil': Timestamp.fromDate(validUntil),
      'settings': settings,
    };
  }

  AvailabilitySchedule copyWith({
    String? providerId,
    List<TimeSlot>? slots,
    DateTime? validFrom,
    DateTime? validUntil,
    Map<String, dynamic>? settings,
  }) {
    return AvailabilitySchedule(
      providerId: providerId ?? this.providerId,
      slots: slots ?? this.slots,
      validFrom: validFrom ?? this.validFrom,
      validUntil: validUntil ?? this.validUntil,
      settings: settings ?? this.settings,
    );
  }

  List<TimeSlot> getAvailableSlots({DateTime? from, DateTime? until}) {
    return slots.where((slot) {
      if (!slot.isAvailable) return false;
      if (from != null && slot.start.isBefore(from)) return false;
      if (until != null && slot.end.isAfter(until)) return false;
      return true;
    }).toList();
  }

  bool hasConflict(TimeSlot newSlot) {
    return slots.any((slot) {
      return !slot.isAvailable &&
          ((newSlot.start.isAfter(slot.start) &&
                  newSlot.start.isBefore(slot.end)) ||
              (newSlot.end.isAfter(slot.start) &&
                  newSlot.end.isBefore(slot.end)) ||
              (newSlot.start.isBefore(slot.start) &&
                  newSlot.end.isAfter(slot.end)));
    });
  }

  bool canBook(TimeSlot slot) {
    return slot.isAvailable &&
        !hasConflict(slot) &&
        slot.start.isAfter(DateTime.now());
  }
}
