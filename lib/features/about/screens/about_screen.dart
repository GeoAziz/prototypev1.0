import 'package:flutter/material.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  _AboutScreenState createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 700),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('About Us')),
      body: FadeTransition(
        opacity: _animation,
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            Center(
              child: Column(
                children: [
                  Icon(Icons.info_outline, size: 64, color: Colors.blue),
                  SizedBox(height: 8),
                  Text(
                    'poafix - Home Services',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text('Version 1.0.0', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Company Info',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              'poafix is a leading platform for home services, connecting users with trusted professionals.',
            ),
            SizedBox(height: 24),
            Text(
              'Terms of Service',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text('Read our terms of service at poafix.com/terms.'),
            SizedBox(height: 24),
            Text(
              'Privacy Policy',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              'Your privacy is important. Read our policy at poafix.com/privacy.',
            ),
            SizedBox(height: 24),
            Text(
              'Contact Information',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text('Email: support@poafix.com'),
            Text('Phone: +1 234 567 890'),
            SizedBox(height: 24),
            Text(
              'Follow Us',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.facebook, color: Colors.blue),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(Icons.alternate_email, color: Colors.lightBlue),
                  onPressed: () {},
                ), // Twitter
                IconButton(
                  icon: Icon(Icons.camera_alt, color: Colors.purple),
                  onPressed: () {},
                ), // Instagram
              ],
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              icon: Icon(Icons.star, color: Colors.amber),
              label: Text('Rate this App'),
              onPressed: () {
                // TODO: Rate app logic
              },
            ),
          ],
        ),
      ),
    );
  }
}
