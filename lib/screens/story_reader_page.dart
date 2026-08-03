import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'profile_view_page.dart';
import '../widgets/avatar.dart';

class StoryReaderPage extends StatelessWidget {
  final String storyId;
  final Map<String, dynamic> data;

  const StoryReaderPage({super.key, required this.storyId, required this.data});

  @override
  Widget build(BuildContext context) {
    final coverColor = colorFromHex(data['coverColor'] as String?);
    final genre = (data['genre'] as String?) ?? 'Story';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [coverColor, coverColor.withOpacity(0.6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                alignment: Alignment.bottomLeft,
                padding: const EdgeInsets.fromLTRB(56, 0, 16, 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(genre, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data['title'] ?? 'Untitled', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      final authorId = data['authorId'] as String?;
                      if (authorId != null) {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => ProfileViewPage(uid: authorId)),
                        );
                      }
                    },
                    child: Row(
                      children: [
                        Icon(Icons.person, size: 16, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 4),
                        Text(
                          data['authorName'] ?? 'Anonymous',
                          style: TextStyle(color: Theme.of(context).colorScheme.primary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(data['content'] ?? '', style: Theme.of(context).textTheme.bodyLarge),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
