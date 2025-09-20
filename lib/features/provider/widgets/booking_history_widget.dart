import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/booking_provider.dart';

class BookingHistoryWidget extends ConsumerWidget {
  final String userId;
  const BookingHistoryWidget({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bookingProvider(userId));
    if (state.isLoading) {
      return const CircularProgressIndicator();
    }
    if (state.bookings.isEmpty) {
      return const Text('No bookings found.');
    }
    return ListView.builder(
      itemCount: state.bookings.length,
      itemBuilder: (context, index) {
        final booking = state.bookings[index];
        return ListTile(
          leading: Icon(Icons.event_available),
          title: Text('Provider: ${booking.providerId}'),
          subtitle: Text(
            'Date: ${booking.bookingTime.toLocal()}\nStatus: ${booking.status}',
          ),
          trailing: Text('KES ${booking.price.toStringAsFixed(2)}'),
        );
      },
    );
  }
}
