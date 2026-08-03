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
        .snapshots();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: chats,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Couldn\'t load chats: ${snapshot.error}', style: const TextStyle(color: Colors.redAccent)));
        }
        final docs = [...(snapshot.data?.docs ?? [])];
        docs.sort((a, b) {
          final aTime = a.data()['lastTimestamp'] as Timestamp?;
          final bTime = b.data()['lastTimestamp'] as Timestamp?;
          if (aTime == null || bTime == null) return 0;
          return bTime.compareTo(aTime);
        });
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
