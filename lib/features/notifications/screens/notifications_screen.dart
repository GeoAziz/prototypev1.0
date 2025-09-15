import 'package:flutter/material.dart';
import 'package:poafix/core/theme/app_colors.dart';
import 'package:poafix/core/theme/app_text_styles.dart';
import 'package:poafix/core/theme/app_icons.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<NotificationItem> _notifications = [
    NotificationItem(
      id: '1',
      title: 'Booking Confirmed',
      message:
          'Your booking for Standard Home Cleaning has been confirmed for tomorrow at 10:00 AM.',
      time: DateTime.now().subtract(const Duration(minutes: 30)),
      isRead: false,
      type: NotificationType.booking,
    ),
    NotificationItem(
      id: '2',
      title: 'Special Offer',
      message:
          'Get 15% off on your next Electrical service booking. Use code ELEC15.',
      time: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: false,
      type: NotificationType.promotion,
    ),
    NotificationItem(
      id: '3',
      title: 'Service Reminder',
      message:
          'Your plumbing service is scheduled for tomorrow at 2:00 PM. Don\'t forget!',
      time: DateTime.now().subtract(const Duration(hours: 5)),
      isRead: true,
      type: NotificationType.booking,
    ),
    NotificationItem(
      id: '4',
      title: 'Payment Successful',
      message:
          'Your payment of \$120 for Standard Home Cleaning has been processed successfully.',
      time: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
      type: NotificationType.payment,
    ),
    NotificationItem(
      id: '5',
      title: 'Rate Your Service',
      message:
          'How was your recent Bathroom Installation service? Please take a moment to rate it.',
      time: DateTime.now().subtract(const Duration(days: 2)),
      isRead: true,
      type: NotificationType.other,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(poafixIcons.more),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => _buildSettingsSheet(),
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
              );
            },
          ),
        ],
      ),
      body: _notifications.isEmpty
          ? _buildEmptyState()
          : ListView.separated(
              itemCount: _notifications.length,
              padding: const EdgeInsets.symmetric(vertical: 8),
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final notification = _notifications[index];
                return _buildNotificationItem(notification);
              },
            ),
    );
  }

  Widget _buildNotificationItem(NotificationItem notification) {
    return InkWell(
      onTap: () {
        setState(() {
          notification.isRead = true;
        });
      },
      child: Container(
        color: notification.isRead
            ? AppColors.white
            : AppColors.primary.withOpacity(0.05),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNotificationIcon(notification.type),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        notification.title,
                        style: AppTextStyles.body1.copyWith(
                          fontWeight: notification.isRead
                              ? FontWeight.normal
                              : FontWeight.bold,
                        ),
                      ),
                      Text(
                        _formatTime(notification.time),
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: AppTextStyles.body2.copyWith(
                      color: notification.isRead
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(NotificationType type) {
    IconData iconData;
    Color backgroundColor;
    Color iconColor;

    switch (type) {
      case NotificationType.booking:
        iconData = poafixIcons.booking;
        backgroundColor = Colors.blue.withOpacity(0.1);
        iconColor = Colors.blue;
        break;
      case NotificationType.payment:
        iconData = poafixIcons.payment;
        backgroundColor = Colors.green.withOpacity(0.1);
        iconColor = Colors.green;
        break;
      case NotificationType.promotion:
        iconData = poafixIcons.favoriteOutline;
        backgroundColor = Colors.orange.withOpacity(0.1);
        iconColor = Colors.orange;
        break;
      case NotificationType.other:
        iconData = poafixIcons.notificationsOutline;
        backgroundColor = AppColors.primary.withOpacity(0.1);
        iconColor = AppColors.primary;
        break;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
      child: Icon(iconData, color: iconColor, size: 20),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            poafixIcons.notificationsOutline,
            size: 64,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text('No Notifications', style: AppTextStyles.headline3),
          const SizedBox(height: 8),
          Text(
            'You\'re all caught up!',
            style: AppTextStyles.body1.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSheet() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Notification Settings', style: AppTextStyles.headline3),
          const SizedBox(height: 16),
          _buildSettingsTile(
            title: 'Mark all as read',
            icon: Icons.check_circle_outline,
            onTap: () {
              setState(() {
                for (var notification in _notifications) {
                  notification.isRead = true;
                }
              });
              Navigator.pop(context);
            },
          ),
          _buildSettingsTile(
            title: 'Clear all notifications',
            icon: Icons.delete_outline,
            onTap: () {
              setState(() {
                _notifications.clear();
              });
              Navigator.pop(context);
            },
          ),
          _buildSettingsTile(
            title: 'Notification preferences',
            icon: Icons.settings,
            onTap: () {
              Navigator.pop(context);
              // Navigate to notification preferences
            },
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }
}

enum NotificationType { booking, payment, promotion, other }

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final DateTime time;
  bool isRead;
  final NotificationType type;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.isRead,
    required this.type,
  });
}
