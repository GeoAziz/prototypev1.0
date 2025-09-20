import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class BookingCalendarWidget extends StatefulWidget {
  final BookingStatus status;
  final Function(String, BookingStatus) onStatusChange;

  const BookingCalendarWidget({
    super.key,
    required this.status,
    required this.onStatusChange,
  });

  @override
  State<BookingCalendarWidget> createState() => _BookingCalendarWidgetState();
}

class _BookingCalendarWidgetState extends State<BookingCalendarWidget> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.week;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableCalendar(
          firstDay: DateTime.now().subtract(const Duration(days: 365)),
          lastDay: DateTime.now().add(const Duration(days: 365)),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          calendarFormat: _calendarFormat,
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
          calendarStyle: const CalendarStyle(
            todayDecoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (_selectedDay != null) _buildBookingsList(),
      ],
    );
  }

  Widget _buildBookingsList() {
    // Replace with Firestore data for selected day
    return StreamBuilder<List<_Booking>>(
      stream: _bookingStream(_selectedDay),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: {snapshot.error}'));
        }
        final bookings = snapshot.data ?? [];
        if (bookings.isEmpty) {
          return const Center(child: Text('No bookings for this day.'));
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bookings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...bookings.map((booking) => _buildBookingCard(booking)).toList(),
          ],
        );
      },
    );
  }

  Stream<List<_Booking>> _bookingStream(DateTime? selectedDay) {
    // Replace with your Firestore query logic
    // Example: Query by providerId and selectedDay
    // This is a placeholder for demonstration
    return const Stream.empty();
  }

  Widget _buildBookingCard(_Booking booking) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: booking.status.color.withOpacity(0.2),
          child: Icon(booking.status.icon, color: booking.status.color),
        ),
        title: Text(booking.customerName),
        subtitle: Text(booking.service),
        trailing: Text(
          booking.time,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        onTap: () {
          // Navigate to booking details
        },
      ),
    );
  }
}

class _Booking {
  final String time;
  final String customerName;
  final String service;
  final BookingStatus status;

  _Booking({
    required this.time,
    required this.customerName,
    required this.service,
    required this.status,
  });
}

enum BookingStatus {
  upcoming(Colors.blue, Icons.schedule),
  inProgress(Colors.green, Icons.play_circle),
  completed(Colors.grey, Icons.check_circle),
  cancelled(Colors.red, Icons.cancel);

  final Color color;
  final IconData icon;

  const BookingStatus(this.color, this.icon);
}
