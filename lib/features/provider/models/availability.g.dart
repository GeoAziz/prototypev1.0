// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'availability.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Availability _$AvailabilityFromJson(Map<String, dynamic> json) => Availability(
  id: json['id'] as String,
  providerId: json['providerId'] as String,
  weeklySchedule: (json['weeklySchedule'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(
      k,
      (e as List<dynamic>)
          .map((e) => TimeSlot.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
  ),
  unavailableDates:
      (json['unavailableDates'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  specialDates:
      (json['specialDates'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
);

Map<String, dynamic> _$AvailabilityToJson(Availability instance) =>
    <String, dynamic>{
      'id': instance.id,
      'providerId': instance.providerId,
      'weeklySchedule': instance.weeklySchedule,
      'unavailableDates': instance.unavailableDates,
      'specialDates': instance.specialDates,
    };

TimeSlot _$TimeSlotFromJson(Map<String, dynamic> json) => TimeSlot(
  startTime: json['startTime'] as String,
  endTime: json['endTime'] as String,
);

Map<String, dynamic> _$TimeSlotToJson(TimeSlot instance) => <String, dynamic>{
  'startTime': instance.startTime,
  'endTime': instance.endTime,
};
