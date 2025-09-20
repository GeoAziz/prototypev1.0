import 'package:flutter/material.dart';
import '../models/availability.dart';
import '../widgets/weekly_schedule.dart';
import '../widgets/break_time_list.dart';

class AvailabilityManagementScreen extends StatefulWidget {
  const AvailabilityManagementScreen({super.key});

  @override
  State<AvailabilityManagementScreen> createState() =>
      _AvailabilityManagementScreenState();
}

class _AvailabilityManagementScreenState
    extends State<AvailabilityManagementScreen> {
  bool _isAvailable = true;
  final Map<String, WorkingHours> _workingHours = {
    'Monday': WorkingHours(startTime: '09:00', endTime: '17:00'),
    'Tuesday': WorkingHours(startTime: '09:00', endTime: '17:00'),
    'Wednesday': WorkingHours(startTime: '09:00', endTime: '17:00'),
    'Thursday': WorkingHours(startTime: '09:00', endTime: '17:00'),
    'Friday': WorkingHours(startTime: '09:00', endTime: '17:00'),
    'Saturday': WorkingHours(startTime: '10:00', endTime: '14:00'),
    'Sunday': WorkingHours(startTime: '', endTime: ''),
  };

  final List<BreakTime> _breakTimes = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Availability')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAvailabilitySwitch(),
            if (_isAvailable) ...[
              const SizedBox(height: 24),
              WeeklySchedule(
                workingHours: _workingHours,
                onUpdate: _updateWorkingHours,
              ),
              const SizedBox(height: 24),
              _buildBreakTimesSection(),
            ],
          ],
        ),
      ),
      floatingActionButton: _isAvailable
          ? FloatingActionButton(
              onPressed: _addBreakTime,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildAvailabilitySwitch() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Available for Bookings',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Switch(
              value: _isAvailable,
              onChanged: (value) {
                setState(() {
                  _isAvailable = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakTimesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Break Times',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        BreakTimeList(breakTimes: _breakTimes, onDelete: _deleteBreakTime),
      ],
    );
  }

  void _updateWorkingHours(String day, WorkingHours hours) {
    setState(() {
      _workingHours[day] = hours;
    });
  }

  void _addBreakTime() async {
    final TimeOfDay? startTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (startTime != null) {
      final TimeOfDay? endTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (endTime != null) {
        setState(() {
          _breakTimes.add(
            BreakTime(
              startTime: startTime.format(context),
              endTime: endTime.format(context),
            ),
          );
        });
      }
    }
  }

  void _deleteBreakTime(int index) {
    setState(() {
      _breakTimes.removeAt(index);
    });
  }
}
