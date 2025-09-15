import 'package:flutter/material.dart';

class WelcomeSlidesScreen extends StatefulWidget {
  const WelcomeSlidesScreen({super.key});

  @override
  _WelcomeSlidesScreenState createState() => _WelcomeSlidesScreenState();
}

class _WelcomeSlidesScreenState extends State<WelcomeSlidesScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _slides = [
    {
      'title': 'Welcome to poafix',
      'desc': 'Find trusted professionals for your home services.',
      'image': 'assets/images/welcome.png',
    },
    {
      'title': 'Book Services Easily',
      'desc': 'Schedule and manage bookings with a few taps.',
      'image': 'assets/images/book.png',
    },
    {
      'title': 'Track & Review',
      'desc': 'Track your bookings and leave reviews for providers.',
      'image': 'assets/images/review.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _controller,
        itemCount: _slides.length,
        onPageChanged: (index) => setState(() => _currentPage = index),
        itemBuilder: (context, index) {
          final slide = _slides[index];
          return AnimatedContainer(
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            color: Colors.blue[(index + 1) * 200],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(slide['image']!, height: 180),
                SizedBox(height: 32),
                Text(
                  slide['title']!,
                  style: TextStyle(
                    fontSize: 28,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Text(
                    slide['desc']!,
                    style: TextStyle(fontSize: 18, color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () => _controller.jumpToPage(_slides.length - 1),
              child: Text('Skip'),
            ),
            Row(
              children: List.generate(
                _slides.length,
                (i) => Container(
                  margin: EdgeInsets.symmetric(horizontal: 2),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == i ? Colors.blue : Colors.grey,
                  ),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                if (_currentPage < _slides.length - 1) {
                  _controller.nextPage(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.ease,
                  );
                } else {
                  Navigator.of(context).pushReplacementNamed('/login');
                }
              },
              child: Text(
                _currentPage == _slides.length - 1 ? 'Start' : 'Next',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
