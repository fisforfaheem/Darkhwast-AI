import 'package:flutter/material.dart';

class AppColors {
  // Primary Palette
  static const Color primary = Color(0xFF0D3B44); // Deep Teal
  static const Color accent = Color(0xFFF5A623);  // Warm Amber
  static const Color background = Color(0xFFF5F4F0); // Warm Off-White
  static const Color surface = Color(0xFFFFFFFF); // Pure White

  // Feedback Colors
  static const Color urgent = Color(0xFFD62828); // Crimson
  static const Color success = Color(0xFF2D6A4F); // Forest Green
  static const Color warning = Color(0xFFF5A623); // Amber (same as accent)

  // Text Colors
  static const Color textPrimary = Color(0xFF1C1C2E); // Near Black
  static const Color textSecondary = Color(0xFF64748B); // Cool Gray
  static const Color textInverse = Color(0xFFFFFFFF);

  // Status Colors
  static const Color statusPending = Color(0xFFF5A623);
  static const Color statusFiled = Color(0xFF2D6A4F);
  static const Color statusResolved = Color(0xFF0D3B44);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, Color(0xFF1A5D69)],
  );
}
