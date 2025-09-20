import 'package:flutter/material.dart';

class BookingDetailScreen extends StatelessWidget {
  const BookingDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Booking Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Customer: Jane Doe'),
            Text('Service: Plumbing'),
            Text('Time: 10:30 AM'),
            Text('Status: Confirmed'),
            SizedBox(height: 16),
            Text('Notes:'),
            Text('"Please bring extra tools."'),
            SizedBox(height: 16),
            ElevatedButton(onPressed: () {}, child: Text('Mark as Completed')),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {},
              child: Text('Cancel Booking'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
