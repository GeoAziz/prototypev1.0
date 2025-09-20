import 'package:flutter/material.dart';

class EarningsChart extends StatelessWidget {
  const EarningsChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Earnings Chart'),
            SizedBox(height: 16),
            LinearProgressIndicator(value: 0.7),
            SizedBox(height: 8),
            Text('KES 12,000 / KES 18,000'),
          ],
        ),
      ),
    );
  }
}
