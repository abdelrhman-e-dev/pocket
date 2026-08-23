import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/dashboard_provider.dart';
import '../widgets/balance_card.dart';
import '../widgets/empty_dashboard.dart';
import '../widgets/recent_transactions.dart';
import '../../../transactions/providers/recent_transactions_with_details_provider.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/dashboard_summary.dart';
import '../widgets/dashboard_accounts.dart';
import '../../providers/dashboard_summary_provider.dart';
import '../../../../shared/components/navigation/app_bottom_navigation.dart';
import '../widgets/income_expense_progress.dart';
import '../../../profile/providers/user_profile_provider.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  bool _nameDialogShown = false;

  void _showNameDialog() {
    if (_nameDialogShown || !mounted) return;
    _nameDialogShown = true;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final controller = TextEditingController();
      final formKey = GlobalKey<FormState>();
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('ما الذي يمكنني مناداتك به؟'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              autofocus: true,
              textDirection: TextDirection.rtl,
              decoration: const InputDecoration(labelText: 'اسمك'),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'من فضلك أدخل اسمك'
                  : null,
            ),
          ),
          actions: [
            FilledButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                await ref
                    .read(userProfileRepositoryProvider)
                    .saveName(controller.text);
                if (context.mounted) Navigator.of(context).pop();
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      );
      controller.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    final accounts = ref.watch(dashboardProvider);
    final transactions = ref.watch(recentTransactionsWithDetailsProvider);
    final summary = ref.watch(dashboardSummaryProvider);
    ref.listen(userProfileProvider, (_, next) {
      if (next.hasValue && next.value == null) _showNameDialog();
    });
    return Scaffold(
      body: accounts.when(
        loading: () => const Center(child: CircularProgressIndicator()),

        error: (e, _) => Center(child: Text(e.toString())),

        data: (items) {
          final profile = ref.watch(userProfileProvider);
          if (items.isNotEmpty && profile.hasValue && profile.value == null) {
            _showNameDialog();
          }
          if (items.isEmpty) {
            return const EmptyDashboard();
          }

          final total = items.fold<double>(
            0,
            (sum, account) => sum + account.currentBalance,
          );
          return summary.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text(error.toString())),
            data: (summaryData) {
              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const SizedBox(height: 40),
                  const DashboardHeader(),

                  const SizedBox(height: 24),

                  BalanceCard(total: total),

                  const SizedBox(height: 24),

                  DashboardSummary(
                    expenses: summaryData.expenses,
                    income: summaryData.income,
                    accountsCount: items.length,
                  ),
                  const SizedBox(height: 24),

                  IncomeExpenseProgress(
                    income: summaryData.income,
                    expenses: summaryData.expenses,
                  ),
                  const SizedBox(height: 24),

                  DashboardAccounts(
                    accounts: items,
                    onViewAll: () {
                      // صفحة الحسابات سنعملها لاحقًا
                    },
                  ),

                  const SizedBox(height: 24),

                  transactions.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),

                    error: (error, stackTrace) => Text(
                      'حدث خطأ أثناء تحميل العمليات',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),

                    data: (items) => RecentTransactions(
                      transactions: items,
                      onViewAll: () {
                        context.push('/transactions');
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/add-transaction');
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const AppBottomNavigation(),
    );
  }
}
