import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/availability_schedule.dart';
import '../widgets/availability_calendar.dart';
import '../repositories/availability_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final availabilityRepositoryProvider = Provider<AvailabilityRepository>((ref) {
  return AvailabilityRepository();
});

final providerScheduleProvider =
    StreamProvider.family<AvailabilitySchedule?, String>((ref, providerId) {
      final repository = ref.watch(availabilityRepositoryProvider);
      return repository.getProviderSchedule(providerId);
    });

class ProviderAvailabilityScreen extends ConsumerStatefulWidget {
  final String providerId;

  const ProviderAvailabilityScreen({Key? key, required this.providerId})
    : super(key: key);

  @override
  ConsumerState<ProviderAvailabilityScreen> createState() =>
      _ProviderAvailabilityScreenState();
}

class _ProviderAvailabilityScreenState
    extends ConsumerState<ProviderAvailabilityScreen> {
  DateTime _selectedDate = DateTime.now();

  Future<void> _addTimeSlot() async {
    final TimeOfDay? startTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (startTime == null) return;

    final TimeOfDay? endTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        DateTime.now().add(const Duration(hours: 1)),
      ),
    );

    if (endTime == null) return;

    final start = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      startTime.hour,
      startTime.minute,
    );

    final end = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      endTime.hour,
      endTime.minute,
    );

    if (end.isBefore(start)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End time must be after start time')),
      );
      return;
    }

    try {
      final repository = ref.read(availabilityRepositoryProvider);
      await repository.addTimeSlot(
        widget.providerId,
        TimeSlot(start: start, end: end, isAvailable: true),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Time slot added successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error adding time slot: $e')));
    }
  }

  Future<void> _editTimeSlot(TimeSlot slot) async {
    final TimeOfDay? startTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(slot.start),
    );

    if (startTime == null) return;

    final TimeOfDay? endTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(slot.end),
    );

    if (endTime == null) return;

    final start = DateTime(
      slot.start.year,
      slot.start.month,
      slot.start.day,
      startTime.hour,
      startTime.minute,
    );

    final end = DateTime(
      slot.end.year,
      slot.end.month,
      slot.end.day,
      endTime.hour,
      endTime.minute,
    );

    if (end.isBefore(start)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End time must be after start time')),
      );
      return;
    }

    try {
      final repository = ref.read(availabilityRepositoryProvider);
      await repository.updateTimeSlot(
        widget.providerId,
        slot,
        slot.copyWith(start: start, end: end),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Time slot updated successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating time slot: $e')));
    }
  }

  Future<void> _deleteTimeSlot(TimeSlot slot) async {
    try {
      final repository = ref.read(availabilityRepositoryProvider);
      await repository.removeTimeSlot(widget.providerId, slot);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Time slot deleted successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error deleting time slot: $e')));
    }
  }

  void _onSlotSelected(TimeSlot slot) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit Time Slot'),
            onTap: () {
              Navigator.pop(context);
              _editTimeSlot(slot);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text(
              'Delete Time Slot',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              Navigator.pop(context);
              _deleteTimeSlot(slot);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheduleAsyncValue = ref.watch(
      providerScheduleProvider(widget.providerId),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Availability')),
      body: scheduleAsyncValue.when(
        data: (schedule) {
          return AvailabilityCalendar(
            slots: schedule?.slots ?? [],
            selectedDate: _selectedDate,
            onDateSelected: (date) {
              setState(() {
                _selectedDate = date;
              });
            },
            onSlotSelected: _onSlotSelected,
            isProvider: true,
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTimeSlot,
        child: const Icon(Icons.add),
      ),
    );
  }
}
