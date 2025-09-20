import 'package:flutter/material.dart';
import '../../../core/utils/app_rating_helper.dart';
import 'support_chat_screen.dart';
import 'support_ticket_screen.dart';
import 'ticket_list_screen.dart';
import 'video_tutorial_screen.dart';
import 'faq_screen.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  _HelpSupportScreenState createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _faqController = TextEditingController();
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
  final List<Map<String, String>> _videoTutorials = [
    {'title': 'Getting Started', 'url': 'assets/videos/tutorial1.mp4'},
    {'title': 'Booking a Service', 'url': 'assets/videos/tutorial2.mp4'},
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
      appBar: AppBar(title: const Text('Help & Support')),
      body: FadeTransition(
        opacity: _animation,
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: <Widget>[
            // Fix: Explicitly type children as List<Widget>
            TextField(
              controller: _faqController,
              decoration: InputDecoration(
                hintText: 'Search FAQ...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (val) {
                setState(() {});
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Popular Topics',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Wrap(
              spacing: 8,
              children: _popularTopics
                  .map((topic) => Chip(label: Text(topic)))
                  .toList(),
            ),
            const SizedBox(height: 24),
            const Text(
              'FAQs',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Browse FAQ'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FaqScreen()),
                );
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.chat),
              label: const Text('Chat with Support'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SupportChatScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Submit a Ticket',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            ListTile(
              leading: const Icon(Icons.confirmation_number),
              title: const Text('View My Tickets'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TicketListScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.add_circle_outline),
              title: const Text('Create New Ticket'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SupportTicketScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Knowledge Base',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            ..._knowledgeBase.map(
              (kb) => ListTile(
                leading: const Icon(Icons.book),
                title: Text(kb),
                onTap: () {},
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Video Tutorials',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            ..._videoTutorials.map(
              (vid) => ListTile(
                leading: const Icon(Icons.play_circle_fill),
                title: Text(vid['title']!),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VideoTutorialScreen(
                        videoUrl: vid['url']!,
                        title: vid['title']!,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Rate & Share',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            ListTile(
              leading: const Icon(Icons.star_outline),
              title: const Text('Rate App'),
              subtitle: const Text('Help us improve with your feedback'),
              onTap: () => AppRatingHelper.requestReview(),
            ),
          ],
        ),
      ),
    );
  }
}
