import 'package:flutter/material.dart';

class FinancialReportScreen extends StatelessWidget {
  const FinancialReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Financial Report')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Earnings: KES 120,000'),
            Text('Payouts: KES 100,000'),
            Text('Pending: KES 20,000'),
            SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: Icon(Icons.receipt_long),
                title: Text('Last Payout'),
                subtitle: Text('KES 10,000 on Sep 10, 2025'),
              ),
            ),
            Card(
              child: ListTile(
                leading: Icon(Icons.trending_up),
                title: Text('Earnings Trend'),
                subtitle: Text('Up 8% from last month'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
