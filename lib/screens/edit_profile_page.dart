import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../widgets/avatar.dart';

class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic> currentData;
  const EditProfilePage({super.key, required this.currentData});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final _usernameCtrl = TextEditingController(text: widget.currentData['username'] ?? '');
  late final _bioCtrl = TextEditingController(text: widget.currentData['bio'] ?? '');
  late String _selectedColor = (widget.currentData['avatarColor'] as String?) ?? avatarColorPalette.first;
  late String _selectedIcon = (widget.currentData['avatarIcon'] as String?) ?? avatarIconPalette.keys.first;
  bool _saving = false;

  Future<void> _save() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    setState(() => _saving = true);
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'username': _usernameCtrl.text.trim(),
      'usernameLower': _usernameCtrl.text.trim().toLowerCase(),
      'bio': _bioCtrl.text.trim(),
      'avatarColor': _selectedColor,
      'avatarIcon': _selectedIcon,
    });
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit profile')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: UserAvatar(
              radius: 44,
              data: {'avatarColor': _selectedColor, 'avatarIcon': _selectedIcon},
            ),
          ),
          const SizedBox(height: 24),
          Text('Avatar color', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: avatarColorPalette.map((hex) {
              final selected = hex == _selectedColor;
              return GestureDetector(
                onTap: () => setState(() => _selectedColor = hex),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colorFromHex(hex),
                    shape: BoxShape.circle,
                    border: selected ? Border.all(color: Colors.white, width: 3) : null,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Text('Avatar icon', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: avatarIconPalette.entries.map((entry) {
              final selected = entry.key == _selectedIcon;
              return GestureDetector(
                onTap: () => setState(() => _selectedIcon = entry.key),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: selected ? colorFromHex(_selectedColor) : Theme.of(context).colorScheme.surfaceContainerHighest,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(entry.value, color: selected ? Colors.white : null),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 28),
          TextField(
            controller: _usernameCtrl,
            decoration: const InputDecoration(labelText: 'Username', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _bioCtrl,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Bio', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Save'),
            ),
          ),
        ],
      ),
    );
  }
}
