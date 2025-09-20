import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/availability_schedule.dart';
import '../widgets/availability_calendar.dart';
// import '../repositories/availability_repository.dart';
import '../../../core/models/provider.dart' as provider_model;
import '../screens/provider_availability_screen.dart';

final selectedTimeSlotProvider = StateProvider<TimeSlot?>((ref) => null);

class BookingScreen extends ConsumerStatefulWidget {
  final provider_model.Provider provider;

  const BookingScreen({Key? key, required this.provider}) : super(key: key);

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  DateTime _selectedDate = DateTime.now();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _confirmBooking() async {
    final selectedSlot = ref.read(selectedTimeSlotProvider);
    if (selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a time slot')),
      );
      return;
    }

    try {
      // Here you would integrate with your booking system
      // For now, we'll just mark the slot as booked
      final repository = ref.read(availabilityRepositoryProvider);
      final bookingId = DateTime.now().millisecondsSinceEpoch.toString();

      await repository.bookTimeSlot(
        widget.provider.id,
        selectedSlot,
        bookingId,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking confirmed successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error confirming booking: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheduleAsyncValue = ref.watch(
      providerScheduleProvider(widget.provider.id),
    );
    final selectedSlot = ref.watch(selectedTimeSlotProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Book Appointment')),
      body: Column(
        children: [
          // Provider Info Card
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: widget.provider.profileImageUrl != null
                        ? NetworkImage(widget.provider.profileImageUrl!)
                        : null,
                    child: widget.provider.profileImageUrl == null
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.provider.businessName,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.provider.rating.toStringAsFixed(1),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Text(
                              ' (${widget.provider.totalRatings} reviews)',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Availability Calendar
          Expanded(
            child: scheduleAsyncValue.when(
              data: (schedule) {
                return AvailabilityCalendar(
                  slots: schedule?.slots ?? [],
                  selectedDate: _selectedDate,
                  onDateSelected: (date) {
                    setState(() {
                      _selectedDate = date;
                    });
                    ref.read(selectedTimeSlotProvider.notifier).state = null;
                  },
                  onSlotSelected: (slot) {
                    ref.read(selectedTimeSlotProvider.notifier).state = slot;
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),
          ),

          // Booking Details
          if (selectedSlot != null)
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Booking Details',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Additional Notes',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _confirmBooking,
                        child: const Text('Confirm Booking'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
