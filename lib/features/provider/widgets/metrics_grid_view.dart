import 'package:flutter/material.dart';

class MetricsGridView extends StatelessWidget {
  const MetricsGridView({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16.0,
      crossAxisSpacing: 16.0,
      children: [
        _buildMetricCard(
          context,
          'Total Earnings',
          '\$1,234',
          Icons.monetization_on,
          Colors.green,
        ),
        _buildMetricCard(
          context,
          'Bookings',
          '12',
          Icons.calendar_today,
          Colors.blue,
        ),
        _buildMetricCard(context, 'Rating', '4.8', Icons.star, Colors.orange),
        _buildMetricCard(
          context,
          'Active Jobs',
          '3',
          Icons.work,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
