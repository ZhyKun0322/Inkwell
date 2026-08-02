import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'find_friends_page.dart';
import 'profile_view_page.dart';

class FriendsPage extends StatelessWidget {
  const FriendsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final me = FirebaseAuth.instance.currentUser;
    if (me == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const FindFriendsPage()),
            ),
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('users').doc(me.uid).snapshots(),
        builder: (context, snapshot) {
          final friendIds = List<String>.from(snapshot.data?.data()?['friendIds'] ?? []);
          if (friendIds.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('No friends yet.'),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const FindFriendsPage()),
                    ),
                    child: const Text('Find friends'),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: friendIds.length,
            itemBuilder: (context, i) {
              final uid = friendIds[i];
              return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
                builder: (context, userSnap) {
                  final data = userSnap.data?.data();
                  if (data == null) return const SizedBox.shrink();
                  return ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(data['username'] ?? ''),
                    subtitle: Text(data['bio'] ?? ''),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => ProfileViewPage(uid: uid)),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
