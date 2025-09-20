import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/widgets/loading_overlay.dart';
import '../../../core/widgets/error_view.dart';
import '../widgets/booking_trends_chart.dart';
import '../widgets/review_list.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/models/booking_analytics.dart';
// import '../models/booking.dart';

class ProviderAnalyticsScreen extends StatefulWidget {
  const ProviderAnalyticsScreen({super.key});

  @override
  State<ProviderAnalyticsScreen> createState() =>
      _ProviderAnalyticsScreenState();
}

class _ProviderAnalyticsScreenState extends State<ProviderAnalyticsScreen> {
  // final _bookingService = BookingService();
  String _selectedPeriod = 'week';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => setState(() => _selectedPeriod = value),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'week', child: Text('This Week')),
              const PopupMenuItem(value: 'month', child: Text('This Month')),
              const PopupMenuItem(value: 'year', child: Text('This Year')),
            ],
          ),
        ],
      ),
      body: StreamBuilder<List<BookingAnalytics>>(
        stream: _getAnalyticsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingOverlay(isLoading: true, child: SizedBox());
          }

          if (snapshot.hasError) {
            return ErrorView(
              error: 'Error loading analytics: ${snapshot.error}',
              onRetry: () => setState(() {}),
            );
          }

          final analytics = snapshot.data ?? [];
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryCards(analytics),
                const SizedBox(height: 24),
                BookingTrendsChart(analytics: analytics),
                const SizedBox(height: 24),
                _buildRevenueChart(analytics),
                const SizedBox(height: 24),
                _buildReviewsSection(),
              ],
            ),
          );
        },
      ),
    );
  }

  Stream<List<BookingAnalytics>> _getAnalyticsStream() {
    final now = DateTime.now();
    DateTime startDate;

    switch (_selectedPeriod) {
      case 'week':
        startDate = now.subtract(const Duration(days: 7));
        break;
      case 'month':
        startDate = DateTime(now.year, now.month, 1);
        break;
      case 'year':
        startDate = DateTime(now.year, 1, 1);
        break;
      default:
        startDate = now.subtract(const Duration(days: 7));
    }

    final providerId = FirebaseService().currentUserId;
    return FirebaseFirestore.instance
        .collection('bookingAnalytics')
        .where('providerId', isEqualTo: providerId)
        .where('date', isGreaterThanOrEqualTo: startDate)
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => BookingAnalytics.fromJson(doc.data()))
              .toList();
        });
  }

  Widget _buildSummaryCards(List<BookingAnalytics> analytics) {
    final totalEarnings = analytics.fold<double>(
      0,
      (sum, item) => sum + item.totalEarnings,
    );
    final totalBookings = analytics.fold<int>(
      0,
      (sum, item) => sum + item.totalBookings,
    );
    final avgRating = analytics.isEmpty
        ? 0.0
        : analytics.fold<double>(0, (sum, item) => sum + item.avgRating) /
              analytics.length;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildSummaryCard(
          'Total Earnings',
          'KES ${totalEarnings.toStringAsFixed(2)}',
          Icons.attach_money,
          Colors.green,
        ),
        _buildSummaryCard(
          'Total Bookings',
          totalBookings.toString(),
          Icons.calendar_today,
          Colors.blue,
        ),
        _buildSummaryCard(
          'Average Rating',
          avgRating.toStringAsFixed(1),
          Icons.star,
          Colors.amber,
        ),
        _buildSummaryCard(
          'Completion Rate',
          '${(analytics.isEmpty ? 0 : (analytics.last.completedBookings / analytics.last.totalBookings * 100)).toStringAsFixed(1)}%',
          Icons.check_circle,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueChart(List<BookingAnalytics> analytics) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Revenue Trend',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text('KES ${value.toInt()}');
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= analytics.length) {
                            return const Text('');
                          }
                          final date = analytics[value.toInt()].date;
                          return Text('${date.month}/${date.day}');
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  minX: 0,
                  maxX: (analytics.length - 1).toDouble(),
                  minY: 0,
                  maxY:
                      analytics
                          .map((a) => a.totalEarnings)
                          .reduce((a, b) => a > b ? a : b) *
                      1.2,
                  lineBarsData: [
                    LineChartBarData(
                      spots: analytics.asMap().entries.map((entry) {
                        return FlSpot(
                          entry.key.toDouble(),
                          entry.value.totalEarnings,
                        );
                      }).toList(),
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.green.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsSection() {
    final providerId = FirebaseService().currentUserId ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recent Reviews', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        ReviewsList(
          providerId: providerId,
          isProvider: true,
          currentUserId: providerId,
        ),
      ],
    );
  }
}
