import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'story_reader_page.dart';

class ForYouPage extends StatelessWidget {
  const ForYouPage({super.key});

  @override
  Widget build(BuildContext context) {
    final stream = FirebaseFirestore.instance
        .collection('stories')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(child: Text('No stories yet — be the first to publish one!'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final doc = docs[i];
            final data = doc.data();
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                title: Text(data['title'] ?? 'Untitled', style: Theme.of(context).textTheme.titleMedium),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    'by ${data['authorName'] ?? 'Anonymous'}\n${_snippet(data['content'])}',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => StoryReaderPage(storyId: doc.id, data: data)),
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _snippet(dynamic content) {
    final text = (content as String?) ?? '';
    return text.length > 120 ? '${text.substring(0, 120)}...' : text;
  }
}
