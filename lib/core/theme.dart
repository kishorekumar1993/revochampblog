import 'package:flutter/material.dart';

const primaryGradient = LinearGradient(
  colors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class BlogUI {
  // Spacing
  static const double padding = 16;
  static const double gap = 12;
  static const double radius = 16;

  // Typography
  static const TextStyle h1 =
      TextStyle(fontSize: 26, fontWeight: FontWeight.w700);

  static const TextStyle h2 =
      TextStyle(fontSize: 20, fontWeight: FontWeight.w600);

  static const TextStyle body =
      TextStyle(fontSize: 16, height: 1.6);

  static const TextStyle caption =
      TextStyle(fontSize: 13, color: Colors.grey);
}