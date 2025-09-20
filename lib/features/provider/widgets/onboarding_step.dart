import 'package:flutter/material.dart';

class OnboardingStep extends StatelessWidget {
  final String title;
  final String description;
  final bool isCompleted;
  final bool isActive;

  const OnboardingStep({
    Key? key,
    required this.title,
    required this.description,
    this.isCompleted = false,
    this.isActive = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted
                  ? Colors.green
                  : isActive
                  ? Theme.of(context).primaryColor
                  : Colors.grey[300],
            ),
            child: Icon(
              isCompleted ? Icons.check : null,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isActive || isCompleted
                        ? Colors.black
                        : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: isActive || isCompleted
                        ? Colors.black87
                        : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
