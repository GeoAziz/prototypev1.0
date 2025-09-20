import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:poafix/core/models/notification_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final _notificationsCollection = FirebaseFirestore.instance.collection(
    'notifications',
  );

  // Stream controller for in-app notifications
  Stream<List<NotificationModel>> get notificationsStream {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value([]);

    return _notificationsCollection
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => NotificationModel.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  Future<void> init() async {
    // Request permission for iOS
    await _fcm.requestPermission(alert: true, badge: true, sound: true);

    // Initialize local notifications
    const initializationSettingsAndroid = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    final initializationSettingsIOS = DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    final initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        // Handle notification tap
        debugPrint('Notification tapped: ${details.payload}');
        _handleNotificationTap(details.payload);
      },
    );

    // Handle FCM messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Get FCM token
    final token = await _fcm.getToken();
    debugPrint('FCM Token: $token');

    // Save token to user document
    if (token != null) {
      await _saveTokenToUser(token);
    }

    // Listen for token refresh
    _fcm.onTokenRefresh.listen(_saveTokenToUser);
  }

  Future<void> _saveTokenToUser(String token) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'fcmTokens': FieldValue.arrayUnion([token]),
      }, SetOptions(merge: true));
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Handling foreground message: ${message.notification?.title}');
    _showLocalNotification(message);
    _saveNotificationToFirestore(message);
  }

  void _handleBackgroundMessage(RemoteMessage message) {
    debugPrint('Handling background message: ${message.notification?.title}');
    _handleNotificationTap(message.data['route']);
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final androidDetails = AndroidNotificationDetails(
      'default_notification_channel',
      'Default Channel',
      channelDescription: 'Default notification channel',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title,
      message.notification?.body,
      details,
      payload: message.data['route'],
    );
  }

  Future<void> _saveNotificationToFirestore(RemoteMessage message) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final notification = NotificationModel(
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: message.notification?.title ?? '',
      body: message.notification?.body ?? '',
      type: _getNotificationTypeFromData(message.data),
      imageUrl: message.notification?.android?.imageUrl,
      data: message.data,
      userId: user.uid,
      createdAt: DateTime.now(),
      actionRoute: message.data['route'],
    );

    await _notificationsCollection
        .doc(notification.id)
        .set(notification.toMap());
  }

  NotificationType _getNotificationTypeFromData(Map<String, dynamic> data) {
    final type = data['type']?.toString().toLowerCase() ?? '';
    switch (type) {
      case 'booking':
        return NotificationType.booking;
      case 'payment':
        return NotificationType.payment;
      case 'promotion':
        return NotificationType.promotion;
      case 'system':
        return NotificationType.system;
      default:
        return NotificationType.other;
    }
  }

  void _handleNotificationTap(String? route) {
    if (route != null && route.isNotEmpty) {
      debugPrint('Navigating to route: $route');
      // Handle navigation using your router
      // context.go(route); // You'll need to handle this differently
    }
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    await _notificationsCollection.doc(notificationId).update({'isRead': true});
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final batch = FirebaseFirestore.instance.batch();
    final notifications = await _notificationsCollection
        .where('userId', isEqualTo: user.uid)
        .where('isRead', isEqualTo: false)
        .get();

    for (var doc in notifications.docs) {
      batch.update(doc.reference, {'isRead': true});
    }

    await batch.commit();
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    await _notificationsCollection.doc(notificationId).delete();
  }

  // Clear all notifications
  Future<void> clearAll() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final batch = FirebaseFirestore.instance.batch();
    final notifications = await _notificationsCollection
        .where('userId', isEqualTo: user.uid)
        .get();

    for (var doc in notifications.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }
}

// Handle background messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Handling background message: ${message.notification?.title}');
  // No need to show local notification here as system will handle it
}
