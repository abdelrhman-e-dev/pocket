import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  String _getGreeting(int hour) {
    if (hour >= 5 && hour < 12) {
      return 'صباح الخير';
    }

    return 'مساء الخير';
  }

  IconData _getGreetingIcon(int hour) {
    if (hour >= 5 && hour < 18) {
      return Icons.wb_sunny_rounded;
    }

    return Icons.nightlight_round;
  }

  String _formatDate(DateTime date) {
    const weekdays = [
      'الإثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد',
    ];

    const months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];

    return '${weekdays[date.weekday - 1]}، '
        '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final now = DateTime.now();

    final greeting = _getGreeting(now.hour);
    final icon = _getGreetingIcon(now.hour);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 22, color: colors.primary),
                    const SizedBox(width: 6),
                    Text(
                      '$greeting، عبد الرحمن',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                Text(
                  _formatDate(now),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: () {
              context.push('/settings');
            },
            icon: Icon(Icons.settings_outlined, color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
