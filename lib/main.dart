import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'auth_gate.dart';
import 'firebase_options.dart';
import 'theme_notifier.dart';
import 'screens/for_you_page.dart';
import 'screens/friends_page.dart';
import 'screens/story_editor_page.dart';
import 'screens/chat_list_page.dart';
import 'screens/my_profile_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: firebaseOptions);
  runApp(const InkwellApp());
}

class InkwellApp extends StatelessWidget {
  const InkwellApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'Inkwell',
          debugShowCheckedModeBanner: false,
          themeMode: mode,
          theme: ThemeData(colorSchemeSeed: const Color(0xFF6B4EFF), useMaterial3: true, brightness: Brightness.light),
          darkTheme: ThemeData(colorSchemeSeed: const Color(0xFF6B4EFF), useMaterial3: true, brightness: Brightness.dark),
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

  final _pages = const [
    ForYouPage(),
    FriendsPage(),
    StoryEditorPage(),
    ChatListPage(),
    MyProfilePage(),
  ];

  final _titles = const ['For You', 'Friends', 'Write', 'Chats', 'Profile'];

  @override
  Widget build(BuildContext context) {
    // Friends and Profile pages provide their own AppBar (need custom actions).
    final needsSharedBar = _index == 0 || _index == 2 || _index == 3;

    return Scaffold(
      appBar: needsSharedBar ? AppBar(title: Text(_titles[_index])) : null,
      body: SafeArea(child: _pages[_index]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.auto_stories_outlined), selectedIcon: Icon(Icons.auto_stories), label: 'For You'),
          NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: 'Friends'),
          NavigationDestination(icon: Icon(Icons.edit_outlined), selectedIcon: Icon(Icons.edit), label: 'Write'),
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline), selectedIcon: Icon(Icons.chat_bubble), label: 'Chat'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
