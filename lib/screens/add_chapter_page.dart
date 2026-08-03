import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddChapterPage extends StatefulWidget {
  final String storyId;
  final int nextChapterNumber;

  const AddChapterPage({super.key, required this.storyId, required this.nextChapterNumber});

  @override
  State<AddChapterPage> createState() => _AddChapterPageState();
}

class _AddChapterPageState extends State<AddChapterPage> {
  late final _titleCtrl = TextEditingController(text: 'Chapter ${widget.nextChapterNumber}');
  final _bodyCtrl = TextEditingController();
  bool _saving = false;

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    final body = _bodyCtrl.text.trim();
    if (title.isEmpty || body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a chapter title and content first')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final storyRef = FirebaseFirestore.instance.collection('stories').doc(widget.storyId);
      await storyRef.collection('chapters').add({
        'title': title,
        'content': body,
        'order': widget.nextChapterNumber,
        'createdAt': FieldValue.serverTimestamp(),
      });
      await storyRef.update({'chapterCount': FieldValue.increment(1)});

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add chapter: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Chapter ${widget.nextChapterNumber}')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: 'Chapter title', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: TextField(
                controller: _bodyCtrl,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  hintText: 'Continue the story...',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.publish),
                label: const Text('Publish chapter'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
