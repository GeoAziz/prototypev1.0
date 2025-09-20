import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../widgets/booking_calendar_widget.dart';

class BookingListView extends StatelessWidget {
  final BookingStatus status;
  final Function(String, BookingStatus) onStatusChange;

  const BookingListView({
    super.key,
    required this.status,
    required this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
    final providerId = ModalRoute.of(context)?.settings.arguments as String?;
    return StreamBuilder<List<Booking>>(
      stream: _bookingStream(providerId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: {snapshot.error}'));
        }
        final bookings = snapshot.data ?? [];
        if (bookings.isEmpty) {
          return Center(child: Text('No bookings found for this status.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final booking = bookings[index];
            return _BookingCard(
              booking: booking,
              onStatusChange: (id, newStatus) async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Change Booking Status'),
                    content: Text(
                      'Are you sure you want to change the status to ${newStatus.toString().split('.').last}?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Confirm'),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  onStatusChange(id, newStatus);
                }
              },
            );
          },
        );
      },
    );
  }

  Stream<List<Booking>> _bookingStream(String? providerId) {
    // Replace with your Firestore query logic
    // Example: Query by providerId and status
    // You may need to adjust this to match your Booking model and Firestore structure
    // This is a placeholder for demonstration
    return const Stream.empty();
  }
}

class _BookingCard extends StatelessWidget {
  final Booking booking;
  final Function(String, BookingStatus) onStatusChange;

  const _BookingCard({required this.booking, required this.onStatusChange});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          ListTile(
            title: Text(
              booking.providerId,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(booking.serviceId),
            trailing: _buildStatusChip(_mapStatus(booking.status)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  _formatDate(booking.bookingTime),
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(width: 16),
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  _formatTime(booking.bookingTime),
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton(
                  context,
                  Icons.check_circle_outline,
                  'Accept',
                  Colors.green,
                  () => onStatusChange(booking.id, BookingStatus.inProgress),
                ),
                _buildActionButton(
                  context,
                  Icons.cancel_outlined,
                  'Reject',
                  Colors.red,
                  () => onStatusChange(booking.id, BookingStatus.cancelled),
                ),
                _buildActionButton(
                  context,
                  Icons.message_outlined,
                  'Message',
                  Colors.blue,
                  () {
                    // Navigate to chat
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(BookingStatus status) {
    Color color;
    String text;
    switch (status) {
      case BookingStatus.upcoming:
        color = Colors.blue;
        text = 'Upcoming';
        break;
      case BookingStatus.inProgress:
        color = Colors.green;
        text = 'In Progress';
        break;
      case BookingStatus.completed:
        color = Colors.purple;
        text = 'Completed';
        break;
      case BookingStatus.cancelled:
        color = Colors.red;
        text = 'Cancelled';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  BookingStatus _mapStatus(String status) {
    switch (status) {
      case 'pending':
        return BookingStatus.upcoming;
      case 'confirmed':
        return BookingStatus.inProgress;
      case 'inProgress':
        return BookingStatus.inProgress;
      case 'completed':
        return BookingStatus.completed;
      case 'cancelled':
        return BookingStatus.cancelled;
      default:
        return BookingStatus.upcoming;
    }
  }

  String _formatDate(DateTime dateTime) {
    return "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final suffix = hour >= 12 ? 'PM' : 'AM';
    final hour12 = hour > 12 ? hour - 12 : hour;
    return "$hour12:$minute $suffix";
  }

  Widget _buildActionButton(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    VoidCallback onPressed,
  ) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: color, size: 20),
      label: Text(label, style: TextStyle(color: color, fontSize: 12)),
    );
  }
}
