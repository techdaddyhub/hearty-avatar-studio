import 'package:flutter/material.dart';

/// Hearty App Logo Widget
/// Renders the romantic intertwined heart brand logo and typography.
class HeartyLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool isDark;

  const HeartyLogo({
    Key? key,
    this.size = 120,
    this.showText = true,
    this.isDark = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final assetPath = isDark
        ? 'assets/images/hearty_icon.png'
        : 'assets/images/hearty_logo.png';

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size * 0.22),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE91E63).withOpacity(0.25),
                blurRadius: size * 0.18,
                spreadRadius: 2,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.asset(
            assetPath,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              // Vector fallback icon if asset is not loaded
              return Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF5252), Color(0xFFFF4081), Color(0xFF7C4DFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(size * 0.22),
                ),
                child: Icon(
                  Icons.favorite,
                  color: Colors.white,
                  size: size * 0.55,
                ),
              );
            },
          ),
        ),
        if (showText) ...[
          const SizedBox(height: 14),
          Text(
            'Hearty',
            style: TextStyle(
              fontSize: size * 0.26,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              foreground: Paint()
                ..shader = const LinearGradient(
                  colors: [Color(0xFFFF80AB), Color(0xFFFF5252), Color(0xFFFFD180)],
                ).createShader(Rect.fromLTWH(0.0, 0.0, size * 2, size)),
            ),
          ),
        ],
      ],
    );
  }
}
