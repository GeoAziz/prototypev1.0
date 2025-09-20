import 'package:json_annotation/json_annotation.dart';

part 'availability.g.dart';

@JsonSerializable()
class Availability {
  final String id;
  final String providerId;
  final Map<String, List<TimeSlot>> weeklySchedule;
  final List<String> unavailableDates;
  final List<String> specialDates;

  Availability({
    required this.id,
    required this.providerId,
    required this.weeklySchedule,
    this.unavailableDates = const [],
    this.specialDates = const [],
  });

  factory Availability.fromJson(Map<String, dynamic> json) =>
      _$AvailabilityFromJson(json);

  Map<String, dynamic> toJson() => _$AvailabilityToJson(this);
}

@JsonSerializable()
class TimeSlot {
  final String startTime;
  final String endTime;

  TimeSlot({required this.startTime, required this.endTime});

  factory TimeSlot.fromJson(Map<String, dynamic> json) =>
      _$TimeSlotFromJson(json);

  Map<String, dynamic> toJson() => _$TimeSlotToJson(this);
}
