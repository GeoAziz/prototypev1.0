import 'full_calendar_screen.dart';
import 'package:flutter/material.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Provider Calendar')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'September 2025',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: Icon(Icons.event_available),
                title: Text('10:30 AM - Plumbing for Jane Doe'),
                subtitle: Text('Confirmed'),
              ),
            ),
            Card(
              child: ListTile(
                leading: Icon(Icons.event_busy),
                title: Text('12:00 PM - Electrical for John Smith'),
                subtitle: Text('Pending'),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const FullCalendarScreen()),
                );
              },
              child: Text('View Full Calendar'),
            ),
          ],
        ),
      ),
    );
  }
}
