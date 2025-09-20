import 'package:flutter/material.dart';

class ServiceFormScreen extends StatelessWidget {
  const ServiceFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add/Edit Service')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Service Name'),
            TextField(),
            SizedBox(height: 16),
            Text('Category'),
            TextField(),
            SizedBox(height: 16),
            Text('Sub-Service'),
            TextField(),
            SizedBox(height: 16),
            Text('Price (Min)'),
            TextField(keyboardType: TextInputType.number),
            SizedBox(height: 8),
            Text('Price (Max, optional)'),
            TextField(keyboardType: TextInputType.number),
            SizedBox(height: 8),
            Text('Currency'),
            TextField(),
            SizedBox(height: 8),
            Text('Pricing Type'),
            DropdownButton<String>(
              value: 'flat',
              items: [
                DropdownMenuItem(value: 'flat', child: Text('Flat')),
                DropdownMenuItem(value: 'hourly', child: Text('Hourly')),
                DropdownMenuItem(value: 'per_unit', child: Text('Per Unit')),
                DropdownMenuItem(
                  value: 'callout_fee',
                  child: Text('Callout Fee'),
                ),
              ],
              onChanged: (v) {},
            ),
            SizedBox(height: 16),
            Text('Description'),
            TextField(maxLines: 3),
            SizedBox(height: 16),
            ElevatedButton(onPressed: () {}, child: Text('Save Service')),
          ],
        ),
      ),
    );
  }
}
