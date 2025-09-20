import 'package:flutter/material.dart';
import 'package:poafix/core/models/booking.dart';
import 'package:poafix/core/services/booking_service.dart';
import 'package:poafix/core/theme/app_colors.dart';
import 'package:poafix/core/theme/app_text_styles.dart';
import 'package:shimmer/shimmer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  String _getCurrentUserId() {
    return FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  final BookingService _bookingService = BookingService();
  String _filterStatus = 'all';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        backgroundColor: AppColors.white,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) => setState(() => _filterStatus = value),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('All')),
              const PopupMenuItem(value: 'booked', child: Text('Booked')),
              const PopupMenuItem(value: 'pending', child: Text('Pending')),
            ],
          ),
        ],
      ),
      body: StreamBuilder<List<Booking>>(
        stream: _bookingService.streamBookingsForUser(_getCurrentUserId()),
        builder: (context, snapshot) {
          final userId = FirebaseAuth.instance.currentUser?.uid;
          if (userId == null) {
            return const Center(
              child: Text(
                'Please log in to view your bookings',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: 3,
              itemBuilder: (context, i) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: SizedBox(
                  height: 100,
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          var bookings = snapshot.data ?? [];
          if (_filterStatus != 'all') {
            bookings = bookings
                .where((b) => b.status == _filterStatus)
                .toList();
          }
          if (bookings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 64,
                    color: AppColors.primary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text('No bookings yet', style: AppTextStyles.headline3),
                  const SizedBox(height: 8),
                  Text(
                    'Your bookings will appear here',
                    style: AppTextStyles.body1.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => setState(() {}),
            child: ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: bookings.length,
              itemBuilder: (context, i) {
                final booking = bookings[i];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    leading: Icon(Icons.build, color: AppColors.primary),
                    title: Text(
                      booking.serviceTitle,
                      style: AppTextStyles.headline3,
                    ),
                    subtitle: Text(
                      'Provider: ${booking.provider}\nDate: ${booking.bookedAt.toLocal().toString().split(".")[0]}',
                      style: AppTextStyles.body2,
                    ),
                    trailing: Text(
                      booking.status,
                      style: AppTextStyles.body1.copyWith(
                        color: booking.status == 'booked'
                            ? Colors.green
                            : AppColors.textSecondary,
                      ),
                    ),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BookingDetailsScreen(booking: booking),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class BookingDetailsScreen extends StatelessWidget {
  final Booking booking;
  const BookingDetailsScreen({required this.booking, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Booking Details')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Service: ${booking.serviceTitle}',
              style: AppTextStyles.headline3,
            ),
            const SizedBox(height: 12),
            Text('Provider: ${booking.provider}', style: AppTextStyles.body1),
            const SizedBox(height: 12),
            Text('Status: ${booking.status}', style: AppTextStyles.body1),
            const SizedBox(height: 12),
            Text(
              'Booked At: ${booking.bookedAt.toLocal().toString().split(".")[0]}',
              style: AppTextStyles.body1,
            ),
            const SizedBox(height: 24),
            if (booking.status == 'pending')
              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.payment),
                  label: const Text('Pay with PayPal'),
                  onPressed: () {
                    GoRouter.of(context).pushNamed(
                      'bookingPayment',
                      extra: {
                        'serviceId': booking.id,
                        'serviceTitle': booking.serviceTitle,
                        'amount': booking.amount,
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
