import 'package:flutter/material.dart';

/// A utility class that generates placeholder images for services
/// This is used for demo purposes only
class ServiceImagePlaceholder extends StatelessWidget {
  final String serviceName;
  final Color backgroundColor;
  final Color textColor;
  final double? width;
  final double? height;
  final double borderRadius;

  const ServiceImagePlaceholder({
    super.key,
    required this.serviceName,
    this.backgroundColor = const Color(0xFFE0F2F1),
    this.textColor = const Color(0xFF00796B),
    this.width,
    this.height = 200,
    this.borderRadius = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    // Get first letter from each word
    final initials = serviceName
        .split(' ')
        .map((word) => word.isNotEmpty ? word[0].toUpperCase() : '')
        .join();

    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_getIconForService(serviceName), size: 36, color: textColor),
            const SizedBox(height: 8),
            Flexible(
              child: Text(
                serviceName,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            Flexible(
              child: Text(
                initials,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor.withOpacity(0.7),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForService(String serviceName) {
    final name = serviceName.toLowerCase();

    if (name.contains('cleaning')) return Icons.cleaning_services;
    if (name.contains('plumbing')) return Icons.plumbing;
    if (name.contains('electrical')) return Icons.electrical_services;
    if (name.contains('appliance')) return Icons.home_repair_service;
    if (name.contains('renovation')) return Icons.construction;
    if (name.contains('painting')) return Icons.format_paint;
    if (name.contains('moving')) return Icons.moving;
    if (name.contains('pest')) return Icons.pest_control;
    if (name.contains('furniture')) return Icons.chair;
    if (name.contains('gardening')) return Icons.yard;

    // Default
    return Icons.handyman;
  }
}
