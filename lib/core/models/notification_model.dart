import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  booking,
  payment,
  promotion,
  system,
  other,
}

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final String? imageUrl;
  final Map<String, dynamic>? data;
  final String userId;
  final DateTime createdAt;
  final bool isRead;
  final String? actionRoute;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.imageUrl,
    this.data,
    required this.userId,
    required this.createdAt,
    this.isRead = false,
    this.actionRoute,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map, String id) {
    return NotificationModel(
      id: id,
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      type: NotificationType.values.firstWhere(
        (e) => e.toString() == 'NotificationType.${map['type']}',
        orElse: () => NotificationType.other,
      ),
      imageUrl: map['imageUrl'],
      data: map['data'],
      userId: map['userId'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      isRead: map['isRead'] ?? false,
      actionRoute: map['actionRoute'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'type': type.toString().split('.').last,
      'imageUrl': imageUrl,
      'data': data,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
      'isRead': isRead,
      'actionRoute': actionRoute,
    };
  }

  NotificationModel copyWith({
    String? title,
    String? body,
    NotificationType? type,
    String? imageUrl,
    Map<String, dynamic>? data,
    String? userId,
    DateTime? createdAt,
    bool? isRead,
    String? actionRoute,
  }) {
    return NotificationModel(
      id: id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      imageUrl: imageUrl ?? this.imageUrl,
      data: data ?? this.data,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      actionRoute: actionRoute ?? this.actionRoute,
    );
  }
}
