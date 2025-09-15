import 'package:flutter/material.dart';

class FilteringSortScreen extends StatefulWidget {
  const FilteringSortScreen({super.key});

  @override
  _FilteringSortScreenState createState() => _FilteringSortScreenState();
}

class _FilteringSortScreenState extends State<FilteringSortScreen> {
  String _selectedSort = 'Price';
  bool _filterAvailable = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Filter & Sort')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            AnimatedSwitcher(
              duration: Duration(milliseconds: 400),
              child: DropdownButton<String>(
                key: ValueKey(_selectedSort),
                value: _selectedSort,
                items: ['Price', 'Rating', 'Distance']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedSort = val!),
              ),
            ),
            SizedBox(height: 24),
            Row(
              children: [
                Text('Available Only'),
                Switch(
                  value: _filterAvailable,
                  onChanged: (val) => setState(() => _filterAvailable = val),
                ),
              ],
            ),
            SizedBox(height: 24),
            ElevatedButton(onPressed: () {}, child: Text('Apply')),
          ],
        ),
      ),
    );
  }
}
