import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:poafix/core/services/firebase_service.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final providerId = FirebaseService().currentUserId;
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('providerId', isEqualTo: providerId)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading notifications: ${snapshot.error}'),
            );
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return Center(child: Text('No notifications yet.'));
          }
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final isRead = data['isRead'] == true;
              final notificationId = docs[index].id;
              return Dismissible(
                key: Key(notificationId),
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 24),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                secondaryBackground: Container(
                  color: Colors.blue,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 24),
                  child: const Icon(Icons.mark_email_read, color: Colors.white),
                ),
                onDismissed: (direction) async {
                  if (direction == DismissDirection.startToEnd) {
                    // Delete notification
                    await FirebaseFirestore.instance
                        .collection('notifications')
                        .doc(notificationId)
                        .delete();
                  } else {
                    // Mark as read
                    await FirebaseFirestore.instance
                        .collection('notifications')
                        .doc(notificationId)
                        .update({'isRead': true});
                  }
                },
                child: Semantics(
                  label: data['title'] ?? 'Notification',
                  child: ListTile(
                    leading: Icon(
                      isRead
                          ? Icons.notifications_none
                          : Icons.notification_important,
                      color: isRead ? Colors.grey : Colors.blue,
                    ),
                    title: Text(
                      data['title'] ?? '',
                      style: TextStyle(
                        fontWeight: isRead
                            ? FontWeight.normal
                            : FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(data['body'] ?? ''),
                    trailing: Text(_formatTimestamp(data['createdAt'])),
                    onTap: () async {
                      // Mark as read
                      await FirebaseFirestore.instance
                          .collection('notifications')
                          .doc(notificationId)
                          .update({'isRead': true});

                      if (!context.mounted) return;

                      // Navigate based on notification type
                      switch (data['type']) {
                        case 'booking':
                          if (data['bookingId'] != null) {
                            Navigator.pushNamed(
                              context,
                              '/booking-details',
                              arguments: {'bookingId': data['bookingId']},
                            );
                          }
                          break;
                        case 'message':
                          if (data['chatId'] != null) {
                            Navigator.pushNamed(
                              context,
                              '/chat',
                              arguments: {'chatId': data['chatId']},
                            );
                          }
                          break;
                        case 'payment':
                          if (data['paymentId'] != null) {
                            Navigator.pushNamed(
                              context,
                              '/payment-details',
                              arguments: {'paymentId': data['paymentId']},
                            );
                          }
                          break;
                        default:
                          // If no specific routing, just mark as read
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Notification marked as read'),
                            ),
                          );
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

String _formatTimestamp(dynamic timestamp) {
  if (timestamp is Timestamp) {
    final dt = timestamp.toDate();
    final now = DateTime.now();
    if (dt.day == now.day && dt.month == now.month && dt.year == now.year) {
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dt.day}/${dt.month}/${dt.year}';
    }
  }
  return '';
}
