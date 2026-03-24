import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class _T {
  static const paper = Color(0xFFF7F4EF);
  static const ink = Color(0xFF0F0E0C);
  static const accent = Color(0xFFC8401E);
  static const accentLight = Color(0xFFFAEEE9);
  static const muted = Color(0xFF6B6760);
  static const border = Color(0xFFDDD9D2);

  static TextStyle display(double size,
          {FontWeight w = FontWeight.w700, Color? color}) =>
      GoogleFonts.playfairDisplay(
        fontSize: size,
        fontWeight: w,
        color: color ?? ink,
        height: 1.2,
      );

  static TextStyle displayItalic(double size, {Color? color}) =>
      GoogleFonts.playfairDisplay(
        fontSize: size,
        fontStyle: FontStyle.italic,
        color: color ?? ink,
        height: 1.4,
      );

  static TextStyle body(double size,
          {FontWeight w = FontWeight.w300, Color? color}) =>
      GoogleFonts.dmSans(
        fontSize: size,
        fontWeight: w,
        color: color ?? ink,
        height: 1.7,
      );

  static TextStyle label(double size, {Color? color}) => GoogleFonts.dmSans(
        fontSize: size,
        fontWeight: FontWeight.w500,
        letterSpacing: size * 0.13,
        color: color ?? muted,
      );
}

class BlogErrorWidget extends StatelessWidget {
  final VoidCallback onRetry;
  final String? message;

  const BlogErrorWidget({
    Key? key,
    required this.onRetry,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        color: _T.accentLight,
              child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                color: _T.accentLight,
                child: const Icon(
                  Icons.wifi_off_rounded,
                  color: _T.accent,
                  size: 28,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Failed to load',
                style: _T.display(18),
              ),
              const SizedBox(height: 8),
              Text(
                message ?? 'Check your connection and try again.',
                style: _T.body(14, color: _T.muted),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _AccentButton(
                label: 'Try Again',
                onTap: onRetry,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Reuse your existing _AccentButton or copy its definition
class _AccentButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _AccentButton({required this.label, required this.onTap});

  @override
  State<_AccentButton> createState() => _AccentButtonState();
}

class _AccentButtonState extends State<_AccentButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          color: _hover ? const Color(0xFFA33318) : _T.accent,
          child: Text(
            widget.label,
            style: _T.label(12, color: Colors.white),
          ),
        ),
      ),
    );
  }
}