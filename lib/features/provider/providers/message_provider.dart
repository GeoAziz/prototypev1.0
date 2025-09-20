import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/message_model.dart';
import '../repositories/message_repository.dart';

part 'message_provider.g.dart';

@riverpod
class MessageState extends _$MessageState {
  @override
  List<Message> build(String userId, String providerId) => [];

  Future<void> loadMessages(String userId, String providerId) async {
    final repo = MessageRepository();
    state = await repo.fetchMessages(userId, providerId);
  }

  Future<void> sendMessage(Message message) async {
    final repo = MessageRepository();
    await repo.sendMessage(message);
    state = [...state, message];
  }
}
