import 'package:flutter/material.dart';

class BreakTime {
  final String startTime;
  final String endTime;

  BreakTime({required this.startTime, required this.endTime});
}

class BreakTimeList extends StatelessWidget {
  final List<BreakTime> breakTimes;
  final Function(int) onDelete;

  const BreakTimeList({
    super.key,
    required this.breakTimes,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (breakTimes.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Text(
              'No break times added',
              style: TextStyle(
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      children: breakTimes.asMap().entries.map((entry) {
        final index = entry.key;
        final breakTime = entry.value;
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(Icons.coffee),
            title: Text('Break Time ${index + 1}'),
            subtitle: Text('${breakTime.startTime} - ${breakTime.endTime}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => onDelete(index),
            ),
          ),
        );
      }).toList(),
    );
  }
}
