import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class FullCalendarScreen extends StatefulWidget {
  const FullCalendarScreen({super.key});

  @override
  State<FullCalendarScreen> createState() => _FullCalendarScreenState();
}

class _FullCalendarScreenState extends State<FullCalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Example events data
  final Map<DateTime, List<String>> _events = {
    DateTime.utc(2025, 9, 16): [
      '10:30 AM - Plumbing for Jane Doe',
      '12:00 PM - Electrical for John Smith',
    ],
    DateTime.utc(2025, 9, 17): ['2:00 PM - Cleaning for Alice Kim'],
  };

  List<String> _getEventsForDay(DateTime day) {
    return _events[DateTime.utc(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Full Calendar')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2025, 1, 1),
              lastDay: DateTime.utc(2025, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              eventLoader: _getEventsForDay,
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_selectedDay != null)
              ..._getEventsForDay(_selectedDay!).map(
                (event) => Card(
                  child: ListTile(
                    leading: Icon(Icons.event),
                    title: Text(event),
                  ),
                ),
              ),
            if (_selectedDay == null) Text('Select a day to view events'),
          ],
        ),
      ),
    );
  }
}
