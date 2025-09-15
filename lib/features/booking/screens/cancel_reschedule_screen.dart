import 'package:flutter/material.dart';

class CancelRescheduleScreen extends StatelessWidget {
  const CancelRescheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cancel/Reschedule')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: Duration(milliseconds: 400),
              child: Text(
                'Choose an action',
                key: ValueKey('choose'),
                style: TextStyle(fontSize: 20),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              icon: Icon(Icons.cancel),
              label: Text('Cancel Booking'),
              onPressed: () {},
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              icon: Icon(Icons.schedule),
              label: Text('Reschedule Booking'),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
