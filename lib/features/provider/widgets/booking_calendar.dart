import 'package:flutter/material.dart';

class BookingCalendar extends StatelessWidget {
  const BookingCalendar({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Booking Calendar'),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(children: [Text('Mon'), Icon(Icons.event_available)]),
                Column(children: [Text('Tue'), Icon(Icons.event_busy)]),
                Column(children: [Text('Wed'), Icon(Icons.event_available)]),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
