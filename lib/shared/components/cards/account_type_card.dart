import 'package:flutter/material.dart';

class AccountTypeCard extends StatelessWidget {
  const AccountTypeCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(16),

      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,

        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),

          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),

          decoration: BoxDecoration(
            color: selected
                ? colors.primary.withValues(alpha: 0.04)
                : colors.surface,

            borderRadius: BorderRadius.circular(16),

            border: Border.all(
              color: selected ? colors.primary : colors.outlineVariant,
              width: selected ? 2 : 1,
            ),
          ),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // =========================
              // Icon
              // =========================
              Container(
                width: 52,
                height: 52,

                decoration: BoxDecoration(
                  color: selected
                      ? colors.primaryContainer
                      : colors.surfaceContainerHigh,

                  borderRadius: BorderRadius.circular(14),
                ),

                child: Icon(icon, size: 27, color: colors.primary),
              ),

              const SizedBox(height: 10),

              // =========================
              // Title
              // =========================
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,

                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 4),

              // =========================
              // Subtitle
              // =========================
              Text(
                subtitle,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,

                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
