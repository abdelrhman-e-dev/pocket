import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/database/app_database.dart';
import '../../../../shared/utils/category_icon_mapper.dart';
import '../../../transactions/models/transaction_type.dart';
import '../../../transactions/providers/category_repository_provider.dart';
import '../../../transactions/providers/transaction_categories_provider.dart';

class CategoriesPage extends ConsumerWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final categoriesAsync = ref.watch(allCategoriesProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: colors.surface,
        appBar: AppBar(
          title: const Text('التصنيفات'),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/settings');
              }
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add_rounded),
              onPressed: () async {
                await context.push('/categories/add');
                ref.invalidate(allCategoriesProvider);
                ref.invalidate(transactionCategoriesProvider(TransactionType.expense));
                ref.invalidate(transactionCategoriesProvider(TransactionType.income));
              },
            ),
          ],
        ),
        body: categoriesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (categories) {
            final expense = categories.where((c) => c.type == 'expense').toList();
            final income = categories.where((c) => c.type == 'income').toList();

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _SectionTitle(title: 'المصروفات'),
                const SizedBox(height: 10),
                ...expense.map((c) => _CategoryTile(category: c)),
                const SizedBox(height: 24),
                _SectionTitle(title: 'الدخل'),
                const SizedBox(height: 10),
                ...income.map((c) => _CategoryTile(category: c)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;
  @override
  Widget build(BuildContext context) => Text(
    title,
    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
  );
}

class _CategoryTile extends ConsumerWidget {
  const _CategoryTile({required this.category});
  final Category category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final color = Color(category.color);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: category.isSystem
              ? null
              : () async {
                  await context.push('/categories/edit', extra: category);
                  ref.invalidate(allCategoriesProvider);
                  ref.invalidate(transactionCategoriesProvider(TransactionType.expense));
                  ref.invalidate(transactionCategoriesProvider(TransactionType.income));
                },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(categoryIconFromKey(category.icon), color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    category.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                if (category.isSystem)
                  Text(
                    'أساسي',
                    style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
                  )
                else
                  IconButton(
                    icon: Icon(Icons.delete_outline_rounded, color: colors.error),
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          title: const Text('حذف التصنيف'),
                          content: const Text('هل أنت متأكد من حذف هذا التصنيف؟'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(dialogContext).pop(false),
                              child: const Text('إلغاء'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.of(dialogContext).pop(true),
                              child: const Text('حذف'),
                            ),
                          ],
                        ),
                      );

                      if (confirmed != true) return;

                      try {
                        await ref
                            .read(categoryRepositoryProvider)
                            .deleteCategory(category.id);

                        ref.invalidate(allCategoriesProvider);
                        ref.invalidate(
                          transactionCategoriesProvider(TransactionType.expense),
                        );
                        ref.invalidate(
                          transactionCategoriesProvider(TransactionType.income),
                        );
                      } catch (error) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(error.toString())),
                        );
                      }
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}