import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'chat_page.dart';
import '../widgets/avatar.dart';

class ChatListPage extends StatelessWidget {
  const ChatListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final me = FirebaseAuth.instance.currentUser;
    if (me == null) return const SizedBox.shrink();

    final chats = FirebaseFirestore.instance
        .collection('chats')
        .where('participants', arrayContains: me.uid)
        .orderBy('lastTimestamp', descending: true)
        .snapshots();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: chats,
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(child: Text('No conversations yet. Add a friend and say hi!'));
        }
        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final data = docs[i].data();
            final participants = List<String>.from(data['participants'] ?? []);
            final otherUid = participants.firstWhere((id) => id != me.uid, orElse: () => '');

            return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              future: FirebaseFirestore.instance.collection('users').doc(otherUid).get(),
              builder: (context, userSnap) {
                final userData = userSnap.data?.data();
                final username = userData?['username'] ?? '...';
                return ListTile(
                  leading: UserAvatar(radius: 20, data: userData),
                  title: Text(username),
                  subtitle: Text(data['lastMessage'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ChatPage(chatId: docs[i].id, otherUid: otherUid, otherUsername: username),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
