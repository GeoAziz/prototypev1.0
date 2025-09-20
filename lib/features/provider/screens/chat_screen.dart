import 'package:flutter/material.dart';
import '../../../core/models/chat_message.dart';
import '../../../core/services/chat_service.dart';
import '../../../core/widgets/loading_overlay.dart';
import '../../../core/widgets/error_view.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_input.dart';

// TODO: Replace with actual user ID from auth
const String currentUserId = 'demo_user_id';

class ChatScreen extends StatefulWidget {
  final String bookingId;
  final String otherUserId;
  final String otherUserName;

  const ChatScreen({
    super.key,
    required this.bookingId,
    required this.otherUserId,
    required this.otherUserName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.otherUserName),
            Text(
              'Booking #${widget.bookingId}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: _showOptions,
          ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: _isSending,
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<ChatMessage>>(
                stream: _chatService.getMessages(widget.bookingId),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return ErrorView(
                      error: 'Error loading messages: ${snapshot.error}',
                      onRetry: () => setState(() {}),
                    );
                  }

                  final messages = snapshot.data ?? [];
                  return ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isMe = message.senderId == currentUserId;
                      return ChatBubble(message: message, isMe: isMe);
                    },
                  );
                },
              ),
            ),
            ChatInput(
              controller: _messageController,
              onSend: _sendMessage,
              onAttachment: _handleAttachment,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSending = true);
    try {
      await _chatService.sendMessage(
        ChatMessage(
          id: '',
          bookingId: widget.bookingId,
          senderId: currentUserId,
          recipientId: widget.otherUserId,
          text: text,
          timestamp: DateTime.now(),
          type: 'text',
        ),
      );
      _messageController.clear();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error sending message: $e')));
    } finally {
      setState(() => _isSending = false);
    }
  }

  Future<void> _handleAttachment() async {
    // TODO: Implement file/image attachment
  }

  void _showOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.block),
            title: const Text('Block User'),
            onTap: () {
              // TODO: Implement block user
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.report),
            title: const Text('Report Issue'),
            onTap: () {
              // TODO: Implement report
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
