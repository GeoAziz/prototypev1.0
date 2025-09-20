import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/message_model.dart';
import '../providers/message_provider.dart';

class MessageWidget extends ConsumerStatefulWidget {
  final String userId;
  final String providerId;
  const MessageWidget({
    super.key,
    required this.userId,
    required this.providerId,
  });

  @override
  ConsumerState<MessageWidget> createState() => _MessageWidgetState();
}

class _MessageWidgetState extends ConsumerState<MessageWidget> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(
      messageStateProvider(widget.userId, widget.providerId),
    );
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final msg = messages[index];
              final isMe = msg.senderId == widget.userId;
              return Align(
                alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 8,
                  ),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isMe ? Colors.blue[100] : Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(msg.text),
                ),
              );
            },
          ),
        ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: () async {
                if (_controller.text.trim().isEmpty) return;
                final msg = Message(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  senderId: widget.userId,
                  receiverId: widget.providerId,
                  text: _controller.text.trim(),
                  timestamp: DateTime.now(),
                );
                await ref
                    .read(
                      messageStateProvider(
                        widget.userId,
                        widget.providerId,
                      ).notifier,
                    )
                    .sendMessage(msg);
                _controller.clear();
              },
            ),
          ],
        ),
      ],
    );
  }
}
