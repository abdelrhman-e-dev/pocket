import 'package:flutter/material.dart';

abstract final class AppTypography {
  static const headlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
  );

  static const headlineMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static const title = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  static const body = TextStyle(
    fontSize: 16,
  );

  static const label = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );
}