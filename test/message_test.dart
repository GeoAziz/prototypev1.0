import 'package:flutter_test/flutter_test.dart';
import 'package:fresh_flutter_project/features/provider/models/message_model.dart';

void main() {
  test('Message model serialization', () {
    final msg = Message(
      id: 'm1',
      senderId: 'u1',
      receiverId: 'p1',
      text: 'Hello',
      timestamp: DateTime.now(),
    );
    final json = msg.toJson();
    final fromJson = Message.fromJson(json);
    expect(fromJson.id, msg.id);
    expect(fromJson.text, msg.text);
  });
}
