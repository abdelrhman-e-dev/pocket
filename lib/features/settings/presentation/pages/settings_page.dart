import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_settings/app_settings.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../../../core/database/database_provider.dart';
import '../../../accounts/providers/account_repository_provider.dart';
import '../../../dashboard/providers/dashboard_provider.dart';
import '../../../dashboard/providers/dashboard_summary_provider.dart';
import '../../../transactions/providers/activity_provider.dart';
import '../../../transactions/providers/all_transactions_provider.dart';
import '../../../transactions/providers/category_repository_provider.dart';
import '../../../transactions/providers/paginated_transactions_provider.dart';
import '../../../transactions/providers/recent_transactions_provider.dart';
import '../../../transactions/providers/recent_transactions_with_details_provider.dart';
import '../../../../shared/components/app_top_bar.dart';
import '../../providers/reminder_settings_provider.dart';
import '../../../app_lock/providers/app_lock_provider.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _isBusy = false;

  Future<void> _exportData() async {
    setState(() => _isBusy = true);
    try {
      await ref.read(dataManagementServiceProvider).exportToExcel();
      if (mounted) {
        _showMessage('تم تجهيز ملف Excel للمشاركة');
      }
    } catch (error) {
      if (mounted) {
        _showMessage('تعذر تصدير البيانات');
      }
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  Future<void> _confirmReset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إعادة ضبط البيانات؟'),
        content: const Text(
          'سيتم حذف الحسابات والتصنيفات والمعاملات والتحويلات نهائياً.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف البيانات'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() => _isBusy = true);
    try {
      await ref.read(dataManagementServiceProvider).resetAllData();
      _invalidateDataProviders();
      if (mounted) {
        _showMessage('تم حذف جميع البيانات');
        context.go('/onboarding');
      }
    } catch (error) {
      if (mounted) {
        _showMessage('تعذر حذف البيانات');
      }
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  void _invalidateDataProviders() {
    ref.invalidate(accountsProvider);
    ref.invalidate(accountRepositoryProvider);
    ref.invalidate(dashboardProvider);
    ref.invalidate(dashboardSummaryProvider);
    ref.invalidate(activityProvider);
    ref.invalidate(allCategoriesProvider);
    ref.invalidate(allTransactionsWithDetailsProvider);
    ref.invalidate(paginatedTransactionsProvider);
    ref.invalidate(recentTransactionsProvider);
    ref.invalidate(recentTransactionsWithDetailsProvider);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: colors.surface,
        appBar: AppTopBar(
          title: 'الإعدادات',
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/dashboard');
              }
            },
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const _ReminderSection(),
            const SizedBox(height: 12),
            const _SecuritySection(),
            const SizedBox(height: 12),
            _SettingsTile(
              icon: Icons.category_outlined,
              title: 'إدارة التصنيفات',
              onTap: () => context.push('/categories'),
            ),
            const SizedBox(height: 12),
            _SettingsTile(
              icon: Icons.file_download_outlined,
              title: 'تصدير البيانات إلى Excel',
              onTap: _isBusy ? null : _exportData,
            ),
            const SizedBox(height: 12),
            _SettingsTile(
              icon: Icons.delete_forever_outlined,
              title: 'إعادة ضبط البيانات',
              onTap: _isBusy ? null : _confirmReset,
            ),
            const SizedBox(height: 12),
            _SettingsTile(
              icon: Icons.info_outline_rounded,
              title: 'عن التطبيق',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _SecuritySection extends ConsumerWidget {
  const _SecuritySection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appLockProvider);
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(16),
      child: SwitchListTile(
        title: const Text('الأمان'),
        subtitle: const Text('قفل التطبيق ببصمة الإصبع'),
        secondary: const Icon(Icons.fingerprint_rounded),
        value: settings.enabled,
        onChanged: settings.initialized
            ? (enabled) async {
                final controller = ref.read(appLockProvider.notifier);
                if (enabled) {
                  final success = await controller.enable();
                  if (!success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'لا توجد وسيلة مصادقة متاحة. فعّل رمز قفل أو بصمة من إعدادات جهاز Samsung: الأمان والخصوصية > القياسات الحيوية والأمان > بصمات الأصابع.',
                        ),
                      ),
                    );
                  }
                } else {
                  await controller.disable();
                }
              }
            : null,
      ),
    );
  }
}

class _ReminderSection extends ConsumerWidget {
  const _ReminderSection();

  Future<void> _pickTime(BuildContext context, WidgetRef ref) async {
    final current = ref.read(reminderSettingsProvider).time;
    final selected = await showTimePicker(
      context: context,
      initialTime: current,
      helpText: 'اختر وقت التذكير اليومي',
    );
    if (selected != null) {
      await ref.read(reminderSettingsProvider.notifier).setTime(selected);
    }
  }

  Future<void> _pickTimezone(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final timezones = ref
        .read(reminderSettingsProvider.notifier)
        .availableTimezones;
    final selected = await showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final query = controller.text.toLowerCase();
          final filtered = timezones
              .where((timezone) => timezone.toLowerCase().contains(query))
              .take(80)
              .toList();
          return AlertDialog(
            title: const Text('المنطقة الزمنية'),
            content: SizedBox(
              width: double.maxFinite,
              height: 420,
              child: Column(
                children: [
                  TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'ابحث عن مدينة أو منطقة',
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) => ListTile(
                        title: Text(filtered[index]),
                        onTap: () => Navigator.pop(context, filtered[index]),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
    controller.dispose();
    if (selected != null) {
      await ref.read(reminderSettingsProvider.notifier).setTimezone(selected);
    }
  }

  String _offsetLabel(String timezone) {
    final localOffset = DateTime.now().timeZoneOffset;
    final selectedOffset = tz.getLocation(timezone).currentTimeZone.offset;
    final difference = Duration(
      milliseconds: selectedOffset - localOffset.inMilliseconds,
    );
    final sign = difference.isNegative ? '-' : '+';
    final absolute = difference.abs();
    final hours = absolute.inHours;
    final minutes = absolute.inMinutes.remainder(60);
    final formatted = minutes == 0 ? '$hours س' : '$hours س و $minutes د';
    return 'فرق التوقيت عن جهازك: $sign$formatted';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(reminderSettingsProvider);
    final timeLabel = MaterialLocalizations.of(
      context,
    ).formatTimeOfDay(settings.time, alwaysUse24HourFormat: false);

    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'التذكيرات',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('تفعيل التذكير اليومي'),
              value: settings.enabled,
              onChanged: (enabled) async {
                await ref
                    .read(reminderSettingsProvider.notifier)
                    .setEnabled(enabled);
              },
            ),
            if (settings.enabled)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.schedule_outlined),
                title: const Text('وقت التذكير'),
                trailing: Text(timeLabel),
                onTap: () => _pickTime(context, ref),
              ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.public_outlined),
              title: const Text('المنطقة الزمنية للتذكير'),
              subtitle: Text(
                '${settings.timezone}\n${_offsetLabel(settings.timezone)}',
              ),
              trailing: const Icon(Icons.chevron_left_rounded),
              onTap: () => _pickTimezone(context, ref),
            ),
            if (settings.permissionDenied)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text('السماح بالتنبيهات مطلوب لتفعيل التذكير.'),
                    ),
                    TextButton(
                      onPressed: () => AppSettings.openAppSettings(
                        type: AppSettingsType.notification,
                      ),
                      child: const Text('فتح الإعدادات'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: colors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              Icon(icon, color: colors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              Icon(Icons.chevron_left_rounded, color: colors.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
