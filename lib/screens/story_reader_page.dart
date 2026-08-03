import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'profile_view_page.dart';
import 'add_chapter_page.dart';
import '../widgets/avatar.dart';

class StoryReaderPage extends StatefulWidget {
  final String storyId;
  final Map<String, dynamic> data;

  const StoryReaderPage({super.key, required this.storyId, required this.data});

  @override
  State<StoryReaderPage> createState() => _StoryReaderPageState();
}

class _StoryReaderPageState extends State<StoryReaderPage> {
  final _pageController = PageController();
  int _currentPage = 0;

  Future<void> _toggleSave(bool currentlySaved) async {
    final me = FirebaseAuth.instance.currentUser;
    if (me == null) return;
    final ref = FirebaseFirestore.instance.collection('users').doc(me.uid);
    try {
      await ref.update({
        'savedStoryIds': currentlySaved
            ? FieldValue.arrayRemove([widget.storyId])
            : FieldValue.arrayUnion([widget.storyId]),
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Couldn\'t update library: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final coverColor = colorFromHex(data['coverColor'] as String?);
    final genre = (data['genre'] as String?) ?? 'Story';
    final me = FirebaseAuth.instance.currentUser;
    final isAuthor = me?.uid == data['authorId'];

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 130,
            pinned: true,
            actions: [
              if (me != null)
                StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance.collection('users').doc(me.uid).snapshots(),
                  builder: (context, snap) {
                    final saved = List<String>.from(snap.data?.data()?['savedStoryIds'] ?? []).contains(widget.storyId);
                    return IconButton(
                      icon: Icon(saved ? Icons.bookmark : Icons.bookmark_border, color: Colors.white),
                      onPressed: () => _toggleSave(saved),
                    );
                  },
                ),
            ],
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
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
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
                ],
              ),
            ),
          ),
        ],
        body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('stories')
              .doc(widget.storyId)
              .collection('chapters')
              .orderBy('order')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Couldn\'t load chapters: ${snapshot.error}'));
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final chapters = snapshot.data!.docs;
            if (chapters.isEmpty) {
              return const Center(child: Text('No chapters yet.'));
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Chapter ${_currentPage + 1} of ${chapters.length} · swipe to continue',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: chapters.length,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    itemBuilder: (context, i) {
                      final chapter = chapters[i].data();
                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(chapter['title'] ?? 'Chapter ${i + 1}', style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: 16),
                            Text(chapter['content'] ?? '', style: Theme.of(context).textTheme.bodyLarge),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                if (chapters.length > 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(chapters.length, (i) {
                        final active = i == _currentPage;
                        return Container(
                          width: active ? 20 : 6,
                          height: 6,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            color: active ? coverColor : Colors.grey.shade400,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        );
                      }),
                    ),
                  ),
                if (isAuthor)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AddChapterPage(storyId: widget.storyId, nextChapterNumber: chapters.length + 1),
                        ),
                      ),
                      icon: const Icon(Icons.add),
                      label: const Text('Add another chapter'),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
