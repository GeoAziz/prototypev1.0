import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  State<AnalyticsDashboardScreen> createState() =>
      _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _fadeController.forward();
  }

  Stream<QuerySnapshot> _providerBookingsStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Return empty stream if not logged in
      return const Stream<QuerySnapshot>.empty();
    }
    return FirebaseFirestore.instance
        .collection('bookings')
        .where('providerId', isEqualTo: user.uid)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics Dashboard')),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: StreamBuilder<QuerySnapshot>(
            stream: _providerBookingsStream(),
            builder: (context, snapshot) {
              num earnings = 0;
              int bookings = 0;
              double satisfaction = 0;
              String topService = '';
              Map<String, int> serviceCounts = {};
              List<Map<String, dynamic>> reviews = [];
              if (snapshot.hasData) {
                final docs = snapshot.data!.docs;
                bookings = docs.length;
                for (var doc in docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  earnings += (data['totalAmount'] is int)
                      ? data['totalAmount']
                      : int.tryParse(data['totalAmount']?.toString() ?? '0') ??
                            0;
                  final service = data['serviceTitle'] ?? data['service'] ?? '';
                  if (service.isNotEmpty) {
                    serviceCounts[service] = (serviceCounts[service] ?? 0) + 1;
                  }
                  if (data['review'] != null) {
                    reviews.add({
                      'customer': data['customer'] ?? 'Customer',
                      'review': data['review'],
                      'rating': data['rating'] ?? 5,
                    });
                  }
                  if (data['rating'] != null) {
                    satisfaction += (data['rating'] is num)
                        ? data['rating'].toDouble()
                        : double.tryParse(data['rating'].toString()) ?? 0.0;
                  }
                }
                if (bookings > 0) satisfaction = satisfaction / bookings;
                if (serviceCounts.isNotEmpty) {
                  topService = serviceCounts.entries
                      .reduce((a, b) => a.value > b.value ? a : b)
                      .key;
                }
              }
              return ListView(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _AnimatedStatCard(
                          icon: Icons.attach_money,
                          label: 'Earnings This Month',
                          value: Text(
                            'KES ${earnings.toInt()}',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          color: Colors.green,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _AnimatedStatCard(
                          icon: Icons.event,
                          label: 'Bookings',
                          value: Text(
                            '$bookings',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _AnimatedStatCard(
                          icon: Icons.star,
                          label: 'Satisfaction',
                          value: Text(
                            bookings > 0
                                ? '${satisfaction.toStringAsFixed(1)}%'
                                : 'N/A',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: Colors.amber,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          color: Colors.amber,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _AnimatedStatCard(
                          icon: Icons.build,
                          label: 'Top Service',
                          value: Text(
                            topService.isNotEmpty ? topService : 'N/A',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: Colors.purple,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          color: Colors.purple,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Revenue Trend',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.bar_chart, color: Colors.blue),
                              SizedBox(width: 8),
                              Text(
                                'Up 12% from last month',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          _StaticBarChart(),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Recent Customer Reviews',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: reviews.isNotEmpty
                          ? reviews
                                .map(
                                  (r) => ListTile(
                                    leading: CircleAvatar(
                                      child: Icon(Icons.person),
                                    ),
                                    title: Text(r['customer'] ?? 'Customer'),
                                    subtitle: Text('"${r['review']}"'),
                                    trailing: Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                    ),
                                  ),
                                )
                                .toList()
                          : [
                              ListTile(
                                leading: CircleAvatar(
                                  child: Icon(Icons.person),
                                ),
                                title: Text('No reviews yet'),
                                subtitle: Text(''),
                              ),
                            ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _AnimatedStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget value;
  final Color color;
  const _AnimatedStatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, color: color, size: 28),
              radius: 28,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  value,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StaticBarChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _Bar(height: 40, color: Colors.blue),
          _Bar(height: 60, color: Colors.blue),
          _Bar(height: 90, color: Colors.green),
          _Bar(height: 70, color: Colors.blue),
          _Bar(height: 100, color: Colors.green),
          _Bar(height: 80, color: Colors.blue),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final double height;
  final Color color;
  const _Bar({required this.height, required this.color});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOut,
      width: 18,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
