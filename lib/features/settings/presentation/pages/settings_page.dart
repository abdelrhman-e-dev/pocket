import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
