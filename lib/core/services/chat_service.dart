import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_message.dart';

class ChatService {
  final _firestore = FirebaseFirestore.instance;

  Stream<List<ChatMessage>> getMessages(String bookingId) {
    return _firestore
        .collection('chats')
        .doc(bookingId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ChatMessage.fromJson(doc.data()))
              .toList(),
        );
  }

  Future<void> sendMessage(ChatMessage message) async {
    final ref = _firestore
        .collection('chats')
        .doc(message.bookingId)
        .collection('messages')
        .doc();
    await ref.set({...message.toJson(), 'id': ref.id});
  }
}
