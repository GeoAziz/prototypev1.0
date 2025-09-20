import '../models/message_model.dart';

class MessageRepository {
  Future<List<Message>> fetchMessages(String userId, String providerId) async {
    // TODO: Replace with actual backend call
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      Message(
        id: 'm1',
        senderId: userId,
        receiverId: providerId,
        text: 'Hello, I would like to book your service.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
      ),
      Message(
        id: 'm2',
        senderId: providerId,
        receiverId: userId,
        text: 'Sure! What time works for you?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
    ];
  }

  Future<void> sendMessage(Message message) async {
    // TODO: Replace with actual backend call
    await Future.delayed(const Duration(milliseconds: 300));
  }
}
