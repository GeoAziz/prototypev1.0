import 'package:flutter/material.dart';

class WorkingHours {
  final String startTime;
  final String endTime;

  WorkingHours({required this.startTime, required this.endTime});
}

class WeeklySchedule extends StatelessWidget {
  final Map<String, WorkingHours> workingHours;
  final Function(String, WorkingHours) onUpdate;

  const WeeklySchedule({
    super.key,
    required this.workingHours,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Working Hours',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...workingHours.entries.map(
          (entry) => _DayScheduleCard(
            day: entry.key,
            hours: entry.value,
            onUpdate: (hours) => onUpdate(entry.key, hours),
          ),
        ),
      ],
    );
  }
}

class _DayScheduleCard extends StatelessWidget {
  final String day;
  final WorkingHours hours;
  final Function(WorkingHours) onUpdate;

  const _DayScheduleCard({
    required this.day,
    required this.hours,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                day,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  Expanded(
                    child: _TimePickerField(
                      label: 'Start',
                      time: hours.startTime,
                      onChanged: (time) {
                        onUpdate(
                          WorkingHours(startTime: time, endTime: hours.endTime),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('to'),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _TimePickerField(
                      label: 'End',
                      time: hours.endTime,
                      onChanged: (time) {
                        onUpdate(
                          WorkingHours(
                            startTime: hours.startTime,
                            endTime: time,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimePickerField extends StatelessWidget {
  final String label;
  final String time;
  final Function(String) onChanged;

  const _TimePickerField({
    required this.label,
    required this.time,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final TimeOfDay? picked = await showTimePicker(
          context: context,
          initialTime: _parseTimeString(time),
        );

        if (picked != null) {
          onChanged(picked.format(context));
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
        ),
        child: Text(
          time.isEmpty ? 'Closed' : time,
          style: time.isEmpty
              ? TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic)
              : null,
        ),
      ),
    );
  }

  TimeOfDay _parseTimeString(String time) {
    if (time.isEmpty) {
      return const TimeOfDay(hour: 9, minute: 0);
    }

    final parts = time.split(':');
    if (parts.length != 2) {
      return const TimeOfDay(hour: 9, minute: 0);
    }

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);

    if (hour == null || minute == null) {
      return const TimeOfDay(hour: 9, minute: 0);
    }

    return TimeOfDay(hour: hour, minute: minute);
  }
}
