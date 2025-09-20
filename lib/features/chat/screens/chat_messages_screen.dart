import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatMessagesScreen extends StatefulWidget {
  final String receiverId;
  final String receiverName;

  const ChatMessagesScreen({
    super.key,
    required this.receiverId,
    required this.receiverName,
  });

  @override
  _ChatMessagesScreenState createState() => _ChatMessagesScreenState();
}

class _ChatMessagesScreenState extends State<ChatMessagesScreen> {
  bool _isTyping = false;
  final bool _isOnline = true;
  final _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {'me': false, 'text': 'Hi, how can I help you?', 'media': null},
    {'me': true, 'text': 'I need a plumber.', 'media': null},
    {'me': false, 'text': 'Sure! Would you like to book now?', 'media': null},
    {'me': true, 'text': '', 'media': 'assets/images/photo.png'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 12,
              backgroundColor: _isOnline ? Colors.green : Colors.grey,
            ),
            SizedBox(width: 8),
            Text('Chat'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.build),
            onPressed: () {
              // Service request shortcut
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                bool isMe = msg['me'];
                return Align(
                  alignment: isMe
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 400),
                    margin: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.blue.shade100 : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: msg['media'] != null
                        ? Image.asset(msg['media'], width: 120)
                        : Text(msg['text']),
                  ),
                );
              },
            ),
          ),
          if (_isTyping)
            Padding(
              padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
              child: Row(
                children: [
                  SizedBox(width: 8),
                  Text('Typing...', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.photo),
                  onPressed: () async {
                    try {
                      final ImagePicker picker = ImagePicker();
                      final XFile? image = await picker.pickImage(
                        source: ImageSource.gallery,
                      );

                      if (image != null) {
                        final ref = FirebaseStorage.instance
                            .ref()
                            .child('chat_media')
                            .child(
                              '${DateTime.now().millisecondsSinceEpoch}.jpg',
                            );

                        await ref.putFile(File(image.path));
                        final url = await ref.getDownloadURL();

                        setState(() {
                          _messages.add({
                            'me': true,
                            'text': '',
                            'media': url,
                            'timestamp': DateTime.now(),
                          });
                        });
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error sharing media: $e')),
                        );
                      }
                    }
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(hintText: 'Type a message...'),
                    onChanged: (val) {
                      setState(() => _isTyping = val.isNotEmpty);
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () async {
                    setState(() => _isTyping = false);
                    final message = _messageController.text.trim();
                    if (message.isEmpty) return;

                    try {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please log in to send messages'),
                          ),
                        );
                        return;
                      }

                      await FirebaseFirestore.instance.collection('chats').add({
                        'senderId': user.uid,
                        'receiverId': widget.receiverId,
                        'message': message,
                        'timestamp': FieldValue.serverTimestamp(),
                        'isRead': false,
                      });

                      _messageController.clear();
                      setState(() {
                        _messages.add({
                          'me': true,
                          'text': message,
                          'media': null,
                          'timestamp': DateTime.now(),
                        });
                      });
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error sending message: $e')),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
