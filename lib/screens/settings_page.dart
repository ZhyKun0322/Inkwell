import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../theme_notifier.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ValueListenableBuilder<ThemeMode>(
        valueListenable: themeModeNotifier,
        builder: (context, mode, _) {
          return ListView(
            children: [
              SwitchListTile(
                title: const Text('Dark mode'),
                value: mode == ThemeMode.dark,
                onChanged: (val) => themeModeNotifier.value = val ? ThemeMode.dark : ThemeMode.light,
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.redAccent),
                title: const Text('Log out', style: TextStyle(color: Colors.redAccent)),
                onTap: () => FirebaseAuth.instance.signOut(),
              ),
            ],
          );
        },
      ),
    );
  }
}
