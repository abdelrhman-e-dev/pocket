import 'package:flutter/widgets.dart';
import '../../../core/theme/spacing.dart';

abstract final class Gaps {
  static const h4 = SizedBox(height: AppSpacing.xs);
  static const h8 = SizedBox(height: AppSpacing.sm);
  static const h16 = SizedBox(height: AppSpacing.md);
  static const h24 = SizedBox(height: AppSpacing.lg);
  static const h32 = SizedBox(height: AppSpacing.xl);

  static const w4 = SizedBox(width: AppSpacing.xs);
  static const w8 = SizedBox(width: AppSpacing.sm);
  static const w16 = SizedBox(width: AppSpacing.md);
  static const w24 = SizedBox(width: AppSpacing.lg);
}