import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../widgets/avatar.dart';

const List<String> storyGenres = [
  'Fantasy', 'Romance', 'Horror', 'Sci-Fi', 'Mystery',
  'Adventure', 'Slice of Life', 'Poetry', 'Other',
];

class StoryEditorPage extends StatefulWidget {
  const StoryEditorPage({super.key});

  @override
  State<StoryEditorPage> createState() => _StoryEditorPageState();
}

class _StoryEditorPageState extends State<StoryEditorPage> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  String _genre = storyGenres.first;
  String _coverColor = avatarColorPalette.first;
  bool _publishing = false;

  Future<void> _publish() async {
    final title = _titleCtrl.text.trim();
    final body = _bodyCtrl.text.trim();
    if (title.isEmpty || body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a title and some content first')),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _publishing = true);
    try {
      final profile = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final authorName = (profile.data()?['username'] as String?) ?? user.displayName ?? 'Anonymous';

      await FirebaseFirestore.instance.collection('stories').add({
        'authorId': user.uid,
        'authorName': authorName,
        'title': title,
        'content': body,
        'genre': _genre,
        'coverColor': _coverColor,
        'createdAt': FieldValue.serverTimestamp(),
        'likeCount': 0,
      });

      if (mounted) {
        _titleCtrl.clear();
        _bodyCtrl.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Published to Inkwell 🎉')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to publish: $e')));
    } finally {
      if (mounted) setState(() => _publishing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _titleCtrl,
            style: Theme.of(context).textTheme.titleLarge,
            decoration: const InputDecoration(hintText: 'Story title', border: InputBorder.none),
          ),
          const Divider(),
          Text('Genre', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: storyGenres.map((g) {
              final selected = g == _genre;
              return ChoiceChip(
                label: Text(g),
                selected: selected,
                onSelected: (_) => setState(() => _genre = g),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Text('Cover color', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            children: avatarColorPalette.map((hex) {
              final selected = hex == _coverColor;
              return GestureDetector(
                onTap: () => setState(() => _coverColor = hex),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: colorFromHex(hex),
                    shape: BoxShape.circle,
                    border: selected ? Border.all(color: Colors.white, width: 3) : null,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _bodyCtrl,
            maxLines: 12,
            minLines: 8,
            decoration: const InputDecoration(
              hintText: 'Once upon a time...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _publishing ? null : _publish,
              icon: _publishing
                  ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.publish),
              label: const Text('Publish'),
            ),
          ),
        ],
      ),
    );
  }
}
