import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help & Support')),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.help_outline),
            title: Text('How do I accept bookings?'),
            subtitle: Text('Go to Bookings > Pending > Accept'),
          ),
          ListTile(
            leading: Icon(Icons.help_outline),
            title: Text('How do I edit my services?'),
            subtitle: Text('Go to Services > Edit'),
          ),
          ListTile(
            leading: Icon(Icons.contact_support),
            title: Text('Contact Support'),
            subtitle: Text('Email: support@poafix.com'),
          ),
        ],
      ),
    );
  }
}
