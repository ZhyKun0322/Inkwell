import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'auth_gate.dart';
import 'firebase_options.dart';
import 'theme_notifier.dart';
import 'widgets/brand.dart';
import 'widgets/avatar.dart';
import 'screens/for_you_page.dart';
import 'screens/friends_page.dart';
import 'screens/story_editor_page.dart';
import 'screens/chat_list_page.dart';
import 'screens/my_profile_page.dart';
import 'screens/library_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: firebaseOptions);
  runApp(const ReadoorApp());
}

class ReadoorApp extends StatelessWidget {
  const ReadoorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'Readoor',
          debugShowCheckedModeBanner: false,
          themeMode: mode,
          theme: ThemeData(
            colorSchemeSeed: const Color(0xFF7C3AED),
            useMaterial3: true,
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFF5F3FA),
            cardTheme: const CardThemeData(
              color: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
            ),
          ),
          darkTheme: ThemeData(colorSchemeSeed: const Color(0xFF7C3AED), useMaterial3: true, brightness: Brightness.dark),
          home: const AuthGate(child: RootShell()),
        );
      },
    );
  }
}

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  void goToWrite() => setState(() => _index = 2);

  List<Widget> get _pages => [
        ForYouPage(onWriteTap: goToWrite),
        const FriendsPage(),
        const StoryEditorPage(),
        const ChatListPage(),
        const MyProfilePage(),
      ];

  final _titles = const ['For You', 'Friends', 'Write a story', 'Chats', 'Profile'];

  @override
  Widget build(BuildContext context) {
    final needsSharedBar = _index == 2 || _index == 3;
    final me = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: needsSharedBar
          ? AppBar(title: Text(_titles[_index]), backgroundColor: Colors.white, foregroundColor: Colors.black)
          : _index == 0
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(64),
                  child: AppBar(
                    backgroundColor: Colors.white,
                    elevation: 0,
                    automaticallyImplyLeading: false,
                    title: const BrandLogo(),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.bookmarks_outlined, color: Colors.black87),
                        tooltip: 'Your Library',
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const LibraryPage()),
                        ),
                      ),
                      if (me != null)
                        StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                          stream: FirebaseFirestore.instance.collection('users').doc(me.uid).snapshots(),
                          builder: (context, snap) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: UserAvatar(radius: 18, data: snap.data?.data()),
                            );
                          },
                        ),
                    ],
                  ),
                )
              : null,
      body: SafeArea(child: _pages[_index]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        backgroundColor: Colors.white,
        destinations: [
          const NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          const NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: 'Friends'),
          NavigationDestination(
            icon: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(gradient: gradientPrimary, shape: BoxShape.circle),
              child: const Icon(Icons.add, color: Colors.white),
            ),
            label: 'Write',
          ),
          const NavigationDestination(icon: Icon(Icons.chat_bubble_outline), selectedIcon: Icon(Icons.chat_bubble), label: 'Chat'),
          const NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
