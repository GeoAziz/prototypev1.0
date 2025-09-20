class ChatMessage {
  final String id;
  final String bookingId;
  final String senderId;
  final String recipientId;
  final String text;
  final DateTime timestamp;
  final String type;

  ChatMessage({
    required this.id,
    required this.bookingId,
    required this.senderId,
    required this.recipientId,
    required this.text,
    required this.timestamp,
    required this.type,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      bookingId: json['bookingId'] as String,
      senderId: json['senderId'] as String,
      recipientId: json['recipientId'] as String,
      text: json['text'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      type: json['type'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookingId': bookingId,
      'senderId': senderId,
      'recipientId': recipientId,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
      'type': type,
    };
  }
}
