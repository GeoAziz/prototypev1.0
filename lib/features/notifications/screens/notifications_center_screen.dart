import 'package:flutter/material.dart';

class NotificationsCenterScreen extends StatefulWidget {
  const NotificationsCenterScreen({super.key});

  @override
  _NotificationsCenterScreenState createState() =>
      _NotificationsCenterScreenState();
}

class _NotificationsCenterScreenState extends State<NotificationsCenterScreen> {
  final List<Map<String, dynamic>> _notifications = [
    {
      'title': 'Booking Confirmed',
      'desc': 'Your booking is confirmed.',
      'category': 'Booking',
      'read': false,
    },
    {
      'title': 'Payment Received',
      'desc': 'Payment was successful.',
      'category': 'Payment',
      'read': true,
    },
    {
      'title': 'Service Reminder',
      'desc': 'Don’t forget your upcoming service.',
      'category': 'Reminder',
      'read': false,
    },
  ];
  String _selectedCategory = 'All';

  List<String> get _categories => ['All', 'Booking', 'Payment', 'Reminder'];

  @override
  Widget build(BuildContext context) {
    final filtered = _selectedCategory == 'All'
        ? _notifications
        : _notifications
              .where((n) => n['category'] == _selectedCategory)
              .toList();
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications Center'),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                for (var n in _notifications) {
                  n['read'] = true;
                }
              });
            },
            child: Text('Clear All', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _categories
                  .map(
                    (cat) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ChoiceChip(
                        label: Text(cat),
                        selected: _selectedCategory == cat,
                        onSelected: (selected) {
                          setState(() => _selectedCategory = cat);
                        },
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final n = filtered[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  color: n['read']
                      ? Colors.grey.shade100
                      : Colors.purple.shade50,
                  child: ListTile(
                    leading: Icon(Icons.notifications, color: Colors.purple),
                    title: Text(n['title']),
                    subtitle: Text(n['desc']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!n['read'])
                          IconButton(
                            icon: Icon(Icons.check, color: Colors.green),
                            onPressed: () {
                              setState(() => n['read'] = true);
                            },
                          ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() => _notifications.remove(n));
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
