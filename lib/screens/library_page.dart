import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../widgets/avatar.dart';
import 'story_reader_page.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final me = FirebaseAuth.instance.currentUser;
    if (me == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(title: const Text('Your Library')),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('users').doc(me.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Couldn\'t load library: ${snapshot.error}'));
          }
          final savedIds = List<String>.from(snapshot.data?.data()?['savedStoryIds'] ?? []);
          if (savedIds.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('Nothing saved yet. Tap the bookmark icon on a story to add it here.', textAlign: TextAlign.center),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: savedIds.length,
            itemBuilder: (context, i) {
              final storyId = savedIds[i];
              return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                future: FirebaseFirestore.instance.collection('stories').doc(storyId).get(),
                builder: (context, storySnap) {
                  if (!storySnap.hasData) {
                    return const SizedBox(height: 72);
                  }
                  final data = storySnap.data!.data();
                  if (data == null) return const SizedBox.shrink();
                  final coverColor = colorFromHex(data['coverColor'] as String?);
                  final chapterCount = (data['chapterCount'] as int?) ?? 1;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: Container(width: 6, height: 40, decoration: BoxDecoration(color: coverColor, borderRadius: BorderRadius.circular(3))),
                      title: Text(data['title'] ?? 'Untitled'),
                      subtitle: Text('by ${data['authorName'] ?? 'Anonymous'} · $chapterCount ${chapterCount == 1 ? 'chapter' : 'chapters'}'),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => StoryReaderPage(storyId: storyId, data: data)),
                      ),
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
