import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final String chatId;
  final String otherUid;
  final String otherUsername;

  const ChatPage({super.key, required this.chatId, required this.otherUid, required this.otherUsername});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _showEmojiPanel = false;

  static const _commonEmojis = [
    '😀', '😂', '🥹', '😍', '😘', '😎', '🤔', '😢', '😡', '🥳',
    '😴', '🤗', '😱', '🙄', '😇', '🤩', '😭', '🙃', '😅', '🫶',
    '👍', '👎', '👏', '🙏', '💪', '🔥', '✨', '💯', '🎉', '❤️',
    '💜', '💔', '⭐', '📚', '✍️', '📖', '☕', '🌙', '☀️', '🐾',
  ];

  void _insertEmoji(String emoji) {
    final text = _msgCtrl.text;
    final selection = _msgCtrl.selection;
    final cursor = selection.start >= 0 ? selection.start : text.length;
    final newText = text.replaceRange(cursor, cursor, emoji);
    _msgCtrl.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: cursor + emoji.length),
    );
  }

  Future<void> _send() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    final me = FirebaseAuth.instance.currentUser;
    if (me == null) return;

    final chatRef = FirebaseFirestore.instance.collection('chats').doc(widget.chatId);
    _msgCtrl.clear();

    await chatRef.set({
      'participants': [me.uid, widget.otherUid],
      'lastMessage': text,
      'lastTimestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await chatRef.collection('messages').add({
      'senderId': me.uid,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final me = FirebaseAuth.instance.currentUser;
    final messages = FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .snapshots();

    return Scaffold(
      appBar: AppBar(title: Text(widget.otherUsername)),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: messages,
              builder: (context, snapshot) {
                final docs = snapshot.data?.docs ?? [];
                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(12),
                  itemCount: docs.length,
                  itemBuilder: (context, i) {
                    final d = docs[i].data();
                    final isMe = d['senderId'] == me?.uid;
                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isMe
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(16),
                              topRight: const Radius.circular(16),
                              bottomLeft: Radius.circular(isMe ? 16 : 4),
                              bottomRight: Radius.circular(isMe ? 4 : 16),
                            ),
                          ),
                          child: Text(
                            d['text'] ?? '',
                            style: TextStyle(color: isMe ? Theme.of(context).colorScheme.onPrimary : null),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(_showEmojiPanel ? Icons.keyboard : Icons.emoji_emotions_outlined),
                        onPressed: () => setState(() => _showEmojiPanel = !_showEmojiPanel),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _msgCtrl,
                          decoration: InputDecoration(
                            hintText: 'Message...',
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                          ),
                          onTap: () {
                            if (_showEmojiPanel) setState(() => _showEmojiPanel = false);
                          },
                          onSubmitted: (_) => _send(),
                        ),
                      ),
                      const SizedBox(width: 4),
                      IconButton.filled(icon: const Icon(Icons.send), onPressed: _send),
                    ],
                  ),
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  child: _showEmojiPanel
                      ? SizedBox(
                          height: 180,
                          child: GridView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
                            itemCount: _commonEmojis.length,
                            itemBuilder: (context, i) => InkWell(
                              onTap: () => _insertEmoji(_commonEmojis[i]),
                              child: Center(child: Text(_commonEmojis[i], style: const TextStyle(fontSize: 22))),
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
