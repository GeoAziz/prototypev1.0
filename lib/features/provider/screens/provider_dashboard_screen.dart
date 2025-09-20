import 'full_calendar_screen.dart';
import 'package:poafix/core/services/firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'calendar_screen.dart';
import 'support_screen.dart';
import '../widgets/add_service_modal.dart';

class _AddServiceForm extends StatefulWidget {
  @override
  State<_AddServiceForm> createState() => _AddServiceFormState();
}

class _AddServiceFormState extends State<_AddServiceForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add New Service',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Service Name',
              border: OutlineInputBorder(),
            ),
            onChanged: (val) {},
            validator: (val) =>
                val == null || val.isEmpty ? 'Enter service name' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
            ),
            onChanged: (val) {},
            validator: (val) =>
                val == null || val.isEmpty ? 'Enter description' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Price (KES)',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            onChanged: (val) {},
            validator: (val) =>
                val == null || val.isEmpty ? 'Enter price' : null,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      // TODO: Save service to backend
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Service added successfully!'),
                        ),
                      );
                    }
                  },
                  child: const Text('Add Service'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AddServiceScreen extends StatelessWidget {
  const AddServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Service')),
      body: const Center(child: Text('Add Service Screen (Demo)')),
    );
  }
}

class ProviderDashboardScreen extends StatefulWidget {
  const ProviderDashboardScreen({super.key});

  @override
  State<ProviderDashboardScreen> createState() =>
      _ProviderDashboardScreenState();
}

class _ProviderDashboardScreenState extends State<ProviderDashboardScreen> {
  Widget _buildStatisticsSection(BuildContext context) {
    final providerId = FirebaseService().currentUserId;
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('bookings')
          .where('providerId', isEqualTo: providerId)
          .snapshots(),
      builder: (context, snapshot) {
        num earnings = 0;
        int bookings = 0;
        double rating = 0;
        num reviewCount = 0;
        if (snapshot.hasData) {
          final docs = snapshot.data!.docs;
          bookings = docs.length;
          for (var doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            earnings += (data['totalAmount'] is int)
                ? data['totalAmount']
                : (data['totalAmount'] ?? 0);
            rating += (data['rating'] ?? 0);
            reviewCount += (data['reviewCount'] ?? 0);
          }
          rating = bookings > 0 ? rating / bookings : 0;
        }
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  Text(
                    'Statistics',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Today',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 600) {
                  return Row(
                    children: [
                      Expanded(
                        child: AnimatedStatCard(
                          title: 'Total Earnings',
                          value: 'KES ${earnings.toStringAsFixed(0)}',
                          icon: Icons.attach_money,
                          color: Colors.green,
                          subtitle: '+15% from yesterday',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: AnimatedStatCard(
                          title: 'Bookings',
                          value: '$bookings Today',
                          icon: Icons.event,
                          color: Colors.blue,
                          subtitle: '2 upcoming',
                        ),
                      ),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      AnimatedStatCard(
                        title: 'Total Earnings',
                        value: 'KES ${earnings.toStringAsFixed(0)}',
                        icon: Icons.attach_money,
                        color: Colors.green,
                      ),
                      const SizedBox(height: 12),
                      AnimatedStatCard(
                        title: 'Bookings',
                        value: '$bookings Today',
                        icon: Icons.event,
                        color: Colors.blue,
                      ),
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 16),
            AnimatedStatCard(
              title: 'Rating',
              value: rating > 0 ? rating.toStringAsFixed(1) : 'N/A',
              icon: Icons.star,
              color: Colors.amber,
              subtitle: 'Based on $reviewCount reviews',
            ),
          ],
        );
      },
    );
  }

  Widget _buildBookingTrendsChart(BuildContext context) {
    // Placeholder for booking trends chart
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      height: 180,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Center(child: Text('Booking Trends Chart (Demo)')),
      ),
    );
  }

  Widget _buildRecentReviews(BuildContext context) {
    // Placeholder for recent reviews
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recent Customer Feedback',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: CircleAvatar(child: Icon(Icons.person)),
                title: Text('Jane Doe'),
                subtitle: Text('Great service!'),
                trailing: Icon(Icons.star, color: Colors.amber),
              ),
              ListTile(
                leading: CircleAvatar(child: Icon(Icons.person)),
                title: Text('John Smith'),
                subtitle: Text('Very professional.'),
                trailing: Icon(Icons.star, color: Colors.amber),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEarningsChart(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Weekly Earnings',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            DropdownButton<String>(
              value: 'This Week',
              items: ['This Week', 'Last Week', 'Last Month'].map((
                String value,
              ) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (_) {},
              underline: const SizedBox(),
              icon: const Icon(Icons.keyboard_arrow_down),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Text(
                        'KES 12,300',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '+23% vs last week',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(child: EarningsBarChart()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSchedule(BuildContext context) {
    final providerId = FirebaseService().currentUserId;
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return Column(
      children: [
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Today's Schedule",
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              icon: const Icon(Icons.calendar_month, size: 20),
              label: const Text('View All'),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CalendarScreen()),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('bookings')
              .where('providerId', isEqualTo: providerId)
              .where(
                'date',
                isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
              )
              .where('date', isLessThan: Timestamp.fromDate(endOfDay))
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: {snapshot.error}'));
            }
            final bookings = snapshot.data?.docs ?? [];
            if (bookings.isEmpty) {
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Center(child: Text('No bookings for today.')),
                ),
              );
            }
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  ...bookings.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return AnimatedBookingTile(
                      time: data['time']?.toString() ?? '',
                      client: data['client']?.toString() ?? '',
                      service: data['service']?.toString() ?? '',
                      status: data['status']?.toString() ?? '',
                    );
                  }).toList(),
                  const Divider(height: 1),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const CalendarScreen(),
                        ),
                      );
                    },
                    child: const Text('View Full Schedule'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      foregroundColor: Colors.blue,
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [const SizedBox(height: 24), _QuickActionsWidget()],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'Provider Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.blue.shade50],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: RefreshIndicator(
          onRefresh: () async {
            try {
              // Refresh Firebase data by invalidating the stream cache
              await FirebaseFirestore.instance.clearPersistence();

              // Refresh UI by forcing a rebuild
              if (mounted) {
                setState(() {});
              }

              // Show success message
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Dashboard refreshed')),
                );
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Error refreshing: $e')));
              }
            }
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileSummary(context),
                  _buildStatisticsSection(context),
                  _buildBookingTrendsChart(context),
                  _buildRecentReviews(context),
                  _buildEarningsChart(context),
                  _buildSchedule(context),
                  _buildQuickActions(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSummary(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.blue.shade100,
              child: const Icon(Icons.person, size: 35, color: Colors.blue),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back,',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Text(
                    'Service Provider',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class AnimatedStatCard extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;
  const AnimatedStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
    super.key,
  });

  @override
  State<AnimatedStatCard> createState() => _AnimatedStatCardState();
}

class _AnimatedStatCardState extends State<AnimatedStatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnim = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnim,
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: widget.color.withOpacity(0.15),
                child: Icon(widget.icon, color: widget.color, size: 28),
                radius: 28,
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      widget.value,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: widget.color,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    if (widget.subtitle != null) ...[
                      SizedBox(height: 2),
                      Text(
                        widget.subtitle!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EarningsBarChart extends StatelessWidget {
  const EarningsBarChart({super.key});

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 2000,
        barTouchData: const BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    days[value.toInt() % 7],
                    style: const TextStyle(fontSize: 12),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(show: false),
        barGroups: [
          BarChartGroupData(
            x: 0,
            barRods: [
              BarChartRodData(toY: 1200, color: Colors.blueAccent, width: 18),
            ],
          ),
          BarChartGroupData(
            x: 1,
            barRods: [
              BarChartRodData(toY: 900, color: Colors.blueAccent, width: 18),
            ],
          ),
          BarChartGroupData(
            x: 2,
            barRods: [
              BarChartRodData(toY: 1500, color: Colors.blueAccent, width: 18),
            ],
          ),
          BarChartGroupData(
            x: 3,
            barRods: [
              BarChartRodData(toY: 800, color: Colors.blueAccent, width: 18),
            ],
          ),
          BarChartGroupData(
            x: 4,
            barRods: [
              BarChartRodData(toY: 1700, color: Colors.blueAccent, width: 18),
            ],
          ),
          BarChartGroupData(
            x: 5,
            barRods: [
              BarChartRodData(toY: 1100, color: Colors.blueAccent, width: 18),
            ],
          ),
          BarChartGroupData(
            x: 6,
            barRods: [
              BarChartRodData(toY: 1400, color: Colors.blueAccent, width: 18),
            ],
          ),
        ],
      ),
    );
  }
}

class AnimatedBookingTile extends StatelessWidget {
  final String time;
  final String client;
  final String service;
  final String status;
  const AnimatedBookingTile({
    required this.time,
    required this.client,
    required this.service,
    required this.status,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor = status == 'Completed' ? Colors.green : Colors.orange;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: statusColor.withOpacity(0.15),
            child: Icon(
              status == 'Completed' ? Icons.check : Icons.schedule,
              color: statusColor,
            ),
          ),
          title: Text('$service for $client'),
          subtitle: Text(time),
          trailing: Text(
            status,
            style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

class _QuickActionsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final actions = [
      {
        'icon': Icons.add,
        'label': 'Add Service',
        'color': Colors.blue,
        'tooltip': 'Add a new service to your profile',
        'onPressed': (BuildContext context) async {
          // Get providerId from FirebaseService
          final providerId = FirebaseService().currentUserId;
          await showAddServiceModal(context, providerId: providerId);
        },
      },
      {
        'icon': Icons.calendar_month,
        'label': 'View Calendar',
        'color': Colors.purple,
        'tooltip': 'View your upcoming bookings',
        'onPressed': (BuildContext context) {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const FullCalendarScreen()));
        },
      },
      {
        'icon': Icons.chat,
        'label': 'Support',
        'color': Colors.orange,
        'tooltip': 'Contact support or get help',
        'onPressed': (BuildContext context) {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const SupportScreen()));
        },
      },
      {
        'icon': Icons.more_horiz,
        'label': 'More',
        'color': Colors.grey,
        'tooltip': 'More actions',
        'onPressed': (BuildContext context) {
          showModalBottomSheet(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            builder: (ctx) => Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  ListTile(
                    leading: Icon(Icons.settings),
                    title: Text('Settings'),
                  ),
                  ListTile(leading: Icon(Icons.logout), title: Text('Logout')),
                ],
              ),
            ),
          );
        },
      },
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        final buttonWidgets = actions.map((action) {
          return Expanded(
            child: Tooltip(
              message: action['tooltip'] as String,
              child: Semantics(
                label: action['label'] as String,
                button: true,
                child: _AnimatedActionButton(
                  icon: action['icon'] as IconData,
                  label: action['label'] as String,
                  color: action['color'] as Color,
                  onPressed: () {
                    if (action['onPressed'] != null) {
                      (action['onPressed'] as Function)(context);
                    }
                  },
                ),
              ),
            ),
          );
        }).toList();

        if (isWide) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [...buttonWidgets],
          );
        } else {
          return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: actions.map((action) {
              return SizedBox(
                width: double.infinity,
                child: Tooltip(
                  message: action['tooltip'] as String,
                  child: Semantics(
                    label: action['label'] as String,
                    button: true,
                    child: _AnimatedActionButton(
                      icon: action['icon'] as IconData,
                      label: action['label'] as String,
                      color: action['color'] as Color,
                      onPressed: () {
                        if (action['onPressed'] != null) {
                          (action['onPressed'] as Function)(context);
                        }
                      },
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        }
      },
    );
  }
}

class _AnimatedActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;
  const _AnimatedActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  State<_AnimatedActionButton> createState() => _AnimatedActionButtonState();
}

class _AnimatedActionButtonState extends State<_AnimatedActionButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        transform: Matrix4.identity()..scale(_pressed ? 0.96 : 1.0),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.color,
            foregroundColor: Colors.white,
            elevation: _pressed ? 2 : 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: Icon(widget.icon),
          label: Text(widget.label),
          onPressed: widget.onPressed,
        ),
      ),
    );
  }
}
