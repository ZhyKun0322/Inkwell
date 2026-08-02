import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class StoryEditorPage extends StatefulWidget {
  const StoryEditorPage({super.key});

  @override
  State<StoryEditorPage> createState() => _StoryEditorPageState();
}

class _StoryEditorPageState extends State<StoryEditorPage> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
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
      // Look up the author's stored username so the feed doesn't need extra reads.
      final profile = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final authorName = (profile.data()?['username'] as String?) ?? user.displayName ?? 'Anonymous';

      await FirebaseFirestore.instance.collection('stories').add({
        'authorId': user.uid,
        'authorName': authorName,
        'title': title,
        'content': body,
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
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _titleCtrl,
            style: Theme.of(context).textTheme.titleLarge,
            decoration: const InputDecoration(
              hintText: 'Story title',
              border: InputBorder.none,
            ),
          ),
          const Divider(),
          Expanded(
            child: TextField(
              controller: _bodyCtrl,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              decoration: const InputDecoration(
                hintText: 'Once upon a time...',
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
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
