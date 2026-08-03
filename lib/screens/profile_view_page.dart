import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'chat_page.dart';
import 'story_reader_page.dart';
import '../widgets/avatar.dart';

class ProfileViewPage extends StatelessWidget {
  final String uid;
  const ProfileViewPage({super.key, required this.uid});

  Future<void> _addFriend(BuildContext context) async {
    final me = FirebaseAuth.instance.currentUser;
    if (me == null || me.uid == uid) return;
    final db = FirebaseFirestore.instance;
    final batch = db.batch();
    batch.update(db.collection('users').doc(me.uid), {
      'friendIds': FieldValue.arrayUnion([uid])
    });
    batch.update(db.collection('users').doc(uid), {
      'friendIds': FieldValue.arrayUnion([me.uid])
    });
    await batch.commit();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Friend added')));
    }
  }

  String _chatIdFor(String a, String b) {
    final ids = [a, b]..sort();
    return ids.join('_');
  }

  @override
  Widget build(BuildContext context) {
    final me = FirebaseAuth.instance.currentUser;
    final isSelf = me?.uid == uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final data = snapshot.data!.data();
          if (data == null) return const Center(child: Text('User not found'));

          final friendIds = List<String>.from(data['friendIds'] ?? []);
          final alreadyFriends = me != null && friendIds.contains(me.uid);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                UserAvatar(radius: 44, data: data),
                const SizedBox(height: 12),
                Text(data['username'] ?? '', style: Theme.of(context).textTheme.headlineSmall),
                if ((data['bio'] as String?)?.isNotEmpty == true)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(data['bio'], textAlign: TextAlign.center),
                  ),
                const SizedBox(height: 16),
                if (!isSelf)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (!alreadyFriends)
                        FilledButton.icon(
                          onPressed: () => _addFriend(context),
                          icon: const Icon(Icons.person_add),
                          label: const Text('Add friend'),
                        )
                      else
                        const Chip(label: Text('Friends'), avatar: Icon(Icons.check, size: 16)),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ChatPage(
                              chatId: _chatIdFor(me!.uid, uid),
                              otherUid: uid,
                              otherUsername: data['username'] ?? '',
                            ),
                          ),
                        ),
                        icon: const Icon(Icons.chat_bubble_outline),
                        label: const Text('Message'),
                      ),
                    ],
                  ),
                const Divider(height: 40),
                Align(alignment: Alignment.centerLeft, child: Text('Stories', style: Theme.of(context).textTheme.titleMedium)),
                const SizedBox(height: 8),
                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('stories')
                      .where('authorId', isEqualTo: uid)
                      .snapshots(),
                  builder: (context, storySnap) {
                    if (storySnap.hasError) {
                      return Text('Couldn\'t load stories: ${storySnap.error}', style: const TextStyle(color: Colors.redAccent));
                    }
                    final docs = [...(storySnap.data?.docs ?? [])];
                    docs.sort((a, b) {
                      final aTime = a.data()['createdAt'] as Timestamp?;
                      final bTime = b.data()['createdAt'] as Timestamp?;
                      if (aTime == null || bTime == null) return 0;
                      return bTime.compareTo(aTime);
                    });
                    if (docs.isEmpty) return const Text('No stories published yet.');
                    return Column(
                      children: docs.map((doc) {
                        final d = doc.data();
                        final coverColor = colorFromHex(d['coverColor'] as String?);
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: Container(width: 6, decoration: BoxDecoration(color: coverColor, borderRadius: BorderRadius.circular(3))),
                            title: Text(d['title'] ?? 'Untitled'),
                            subtitle: Text((d['genre'] as String?) ?? 'Story'),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => StoryReaderPage(storyId: doc.id, data: d)),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
