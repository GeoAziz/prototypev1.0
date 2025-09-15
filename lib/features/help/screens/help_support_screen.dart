import 'package:flutter/material.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  _HelpSupportScreenState createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _faqController = TextEditingController();
  final List<String> _faqs = [
    'How do I book a service?',
    'How do I cancel a booking?',
    'How do I contact support?',
    'How do I change my address?',
    'How do I add a payment method?',
  ];
  final List<String> _popularTopics = [
    'Booking Issues',
    'Payment Problems',
    'Provider Info',
    'App Features',
  ];
  final List<String> _knowledgeBase = [
    'Booking Process',
    'Payment Methods',
    'Service Provider Info',
    'App Usage Tips',
  ];
  final List<String> _videoTutorials = [
    'assets/videos/tutorial1.mp4',
    'assets/videos/tutorial2.mp4',
  ];
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
      appBar: AppBar(title: Text('Help & Support')),
      body: FadeTransition(
        opacity: _animation,
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            TextField(
              controller: _faqController,
              decoration: InputDecoration(
                hintText: 'Search FAQ...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (val) {
                setState(() {});
              },
            ),
            SizedBox(height: 24),
            Text(
              'Popular Topics',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Wrap(
              spacing: 8,
              children: _popularTopics
                  .map((topic) => Chip(label: Text(topic)))
                  .toList(),
            ),
            SizedBox(height: 24),
            Text(
              'FAQs',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            ..._faqs
                .where(
                  (faq) =>
                      _faqController.text.isEmpty ||
                      faq.toLowerCase().contains(
                        _faqController.text.toLowerCase(),
                      ),
                )
                .map(
                  (faq) => ListTile(
                    leading: Icon(Icons.help_outline),
                    title: Text(faq),
                    onTap: () {},
                  ),
                ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              icon: Icon(Icons.chat),
              label: Text('Chat with Support'),
              onPressed: () {
                // TODO: Chat with support
              },
            ),
            SizedBox(height: 24),
            Text(
              'Submit a Ticket',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            ListTile(
              leading: Icon(Icons.confirmation_number),
              title: Text('Open Ticket'),
              onTap: () {
                // TODO: Ticket system
              },
            ),
            SizedBox(height: 24),
            Text(
              'Knowledge Base',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            ..._knowledgeBase.map(
              (kb) => ListTile(
                leading: Icon(Icons.book),
                title: Text(kb),
                onTap: () {},
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Video Tutorials',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            ..._videoTutorials.map(
              (vid) => ListTile(
                leading: Icon(Icons.play_circle_fill),
                title: Text('Watch Tutorial'),
                onTap: () {
                  // TODO: Play video
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
