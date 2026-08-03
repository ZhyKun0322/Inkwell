import 'package:flutter/material.dart';

const gradientPrimary = LinearGradient(
  colors: [Color(0xFF7C3AED), Color(0xFFEC4899)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class BrandLogo extends StatelessWidget {
  final double fontSize;
  const BrandLogo({super.key, this.fontSize = 24});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: fontSize,
          margin: const EdgeInsets.only(right: 3),
          decoration: BoxDecoration(color: const Color(0xFF7C3AED), borderRadius: BorderRadius.circular(2)),
        ),
        Container(
          width: 6,
          height: fontSize,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(color: const Color(0xFFEC4899), borderRadius: BorderRadius.circular(2)),
        ),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Read',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontWeight: FontWeight.bold,
                  fontSize: fontSize,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
              TextSpan(
                text: 'oor',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontWeight: FontWeight.bold,
                  fontSize: fontSize,
                  foreground: Paint()
                    ..shader = gradientPrimary.createShader(Rect.fromLTWH(0, 0, 100, 40)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Small pill button with the gradient fill used across the app (e.g. "+ New Story").
class GradientButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onPressed;

  const GradientButton({super.key, required this.label, this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: const BoxDecoration(gradient: gradientPrimary),
          child: InkWell(
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: Colors.white, size: 18),
                    const SizedBox(width: 6),
                  ],
                  Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
