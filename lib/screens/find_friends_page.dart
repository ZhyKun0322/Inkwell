import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'profile_view_page.dart';

class FindFriendsPage extends StatefulWidget {
  const FindFriendsPage({super.key});

  @override
  State<FindFriendsPage> createState() => _FindFriendsPageState();
}

class _FindFriendsPageState extends State<FindFriendsPage> {
  final _searchCtrl = TextEditingController();
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _results = [];
  bool _loading = false;

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _results = []);
      return;
    }
    setState(() => _loading = true);
    final q = query.trim().toLowerCase();
    final snap = await FirebaseFirestore.instance
        .collection('users')
        .orderBy('usernameLower')
        .startAt([q])
        .endAt(['$q\uf8ff'])
        .limit(20)
        .get();
    setState(() {
      _results = snap.docs.where((d) => d.id != FirebaseAuth.instance.currentUser?.uid).toList();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Find friends')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchCtrl,
              onChanged: _search,
              decoration: const InputDecoration(
                hintText: 'Search by username',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          if (_loading) const CircularProgressIndicator(),
          Expanded(
            child: ListView.builder(
              itemCount: _results.length,
              itemBuilder: (context, i) {
                final doc = _results[i];
                final data = doc.data();
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(data['username'] ?? ''),
                  subtitle: Text(data['bio'] ?? ''),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => ProfileViewPage(uid: doc.id)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
