import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/availability_schedule.dart';

class AvailabilityCalendar extends StatefulWidget {
  final List<TimeSlot> slots;
  final DateTime? selectedDate;
  final Function(DateTime) onDateSelected;
  final Function(TimeSlot)? onSlotSelected;
  final bool isProvider;

  const AvailabilityCalendar({
    Key? key,
    required this.slots,
    this.selectedDate,
    required this.onDateSelected,
    this.onSlotSelected,
    this.isProvider = false,
  }) : super(key: key);

  @override
  State<AvailabilityCalendar> createState() => _AvailabilityCalendarState();
}

class _AvailabilityCalendarState extends State<AvailabilityCalendar> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  late Map<DateTime, List<TimeSlot>> _events;

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.selectedDate ?? DateTime.now();
    _selectedDay = widget.selectedDate ?? DateTime.now();
    _updateEvents();
  }

  @override
  void didUpdateWidget(AvailabilityCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.slots != widget.slots) {
      _updateEvents();
    }
  }

  void _updateEvents() {
    _events = {};
    for (final slot in widget.slots) {
      final day = DateTime(slot.start.year, slot.start.month, slot.start.day);
      _events[day] = [...(_events[day] ?? []), slot];
    }
  }

  List<TimeSlot> _getEventsForDay(DateTime day) {
    return _events[day] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableCalendar(
          firstDay: DateTime.now(),
          lastDay: DateTime.now().add(const Duration(days: 365)),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          eventLoader: _getEventsForDay,
          startingDayOfWeek: StartingDayOfWeek.monday,
          calendarStyle: CalendarStyle(
            markersMaxCount: 1,
            markerDecoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
          ),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
            widget.onDateSelected(selectedDay);
          },
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: _getEventsForDay(_selectedDay).length,
            itemBuilder: (context, index) {
              final slot = _getEventsForDay(_selectedDay)[index];
              return _TimeSlotTile(
                slot: slot,
                onTap:
                    widget.onSlotSelected != null &&
                        (widget.isProvider || slot.isAvailable)
                    ? () => widget.onSlotSelected!(slot)
                    : null,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _TimeSlotTile extends StatelessWidget {
  final TimeSlot slot;
  final VoidCallback? onTap;

  const _TimeSlotTile({Key? key, required this.slot, this.onTap})
    : super(key: key);

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_formatTime(slot.start)} - ${_formatTime(slot.end)}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    slot.isAvailable ? 'Available' : 'Booked',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: slot.isAvailable ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              if (onTap != null)
                Icon(
                  slot.isAvailable
                      ? Icons.calendar_today
                      : Icons.calendar_today_outlined,
                  color: Theme.of(context).primaryColor,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
