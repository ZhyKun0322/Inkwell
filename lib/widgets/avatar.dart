import 'package:flutter/material.dart';

/// Palette users pick from for their avatar background / story cover color.
const List<String> avatarColorPalette = [
  '6B4EFF', 'FF6B9D', '4ECDC4', 'FFD166',
  '06A77D', 'EF476F', '118AB2', 'F78C6B',
];

/// Icon choices users pick from for their avatar.
const Map<String, IconData> avatarIconPalette = {
  'person': Icons.person,
  'star': Icons.star,
  'favorite': Icons.favorite,
  'pets': Icons.pets,
  'auto_stories': Icons.auto_stories,
  'nightlight': Icons.nightlight_round,
  'local_fire_department': Icons.local_fire_department,
  'bolt': Icons.bolt,
};

Color colorFromHex(String? hex) {
  if (hex == null || hex.isEmpty) return const Color(0xFF6B4EFF);
  return Color(int.parse('FF$hex', radix: 16));
}

IconData iconFromName(String? name) {
  return avatarIconPalette[name] ?? Icons.person;
}

/// A colored, iconed avatar built from a user's stored customization.
class UserAvatar extends StatelessWidget {
  final Map<String, dynamic>? data;
  final double radius;

  const UserAvatar({super.key, required this.data, this.radius = 24});

  @override
  Widget build(BuildContext context) {
    final color = colorFromHex(data?['avatarColor'] as String?);
    final icon = iconFromName(data?['avatarIcon'] as String?);
    return CircleAvatar(
      radius: radius,
      backgroundColor: color,
      child: Icon(icon, color: Colors.white, size: radius),
    );
  }
}
