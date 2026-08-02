import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'profile_view_page.dart';

class StoryReaderPage extends StatelessWidget {
  final String storyId;
  final Map<String, dynamic> data;

  const StoryReaderPage({super.key, required this.storyId, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(data['title'] ?? 'Untitled')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(data['title'] ?? 'Untitled', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                final authorId = data['authorId'] as String?;
                if (authorId != null) {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => ProfileViewPage(uid: authorId)),
                  );
                }
              },
              child: Text(
                'by ${data['authorName'] ?? 'Anonymous'}',
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ),
            const SizedBox(height: 20),
            Text(data['content'] ?? '', style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}
