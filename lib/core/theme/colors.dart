import 'package:flutter/material.dart';

abstract final class AppColors {
  AppColors._();

  // Primary
  static const primary = Color(0xFF3B82F6);
  static const secondary = Color(0xFF10B981);

  // Backgrounds
  static const background = Color(0xFF0F172A);
  static const surface = Color(0xFF1E293B);
  static const card = Color(0xFF334155);

  // Status
  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);

  // Text
  static const textPrimary = Color(0xFFF8FAFC);
  static const textSecondary = Color(0xFFCBD5E1);

  // Borders
  static const border = Color(0xFF475569);

  // Others
  static const transparent = Colors.transparent;
}