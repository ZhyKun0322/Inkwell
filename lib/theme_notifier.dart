import 'package:flutter/material.dart';

/// Simple global notifier — Settings page flips this, MaterialApp listens to it.
final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(ThemeMode.dark);
