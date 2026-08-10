import 'package:flutter/material.dart';



class TransactionCategoryGrid extends StatelessWidget {
  const TransactionCategoryGrid({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
  });

  final List categories;
  final int? selectedCategoryId;
  final ValueChanged<int> onCategorySelected;

  static const int _visibleCount = 7;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }

    final hasMore = categories.length > _visibleCount;

    final visibleCategories = hasMore
        ? categories.take(_visibleCount).toList()
        : categories;

    final items = [
      ...visibleCategories.map(
        (category) => _CategoryItem(
          category: category,
          selected: selectedCategoryId == category.id,
          onTap: () => onCategorySelected(category.id),
        ),
      ),
      if (hasMore)
        _MoreCategoryItem(
          onTap: () => _showAllCategories(context),
        ),
    ];

    return GridView.count(
      crossAxisCount: 4,
      crossAxisSpacing: 12,
      mainAxisSpacing: 14,
      childAspectRatio: 0.85,
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      children: items,
    );
  }

  void _showAllCategories(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .outlineVariant,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

          

                Text(
                  'اختر التصنيف',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),

          

                Flexible(
                  child: GridView.builder(
                    shrinkWrap: true,
                    itemCount: categories.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 30,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.9,
                    ),
                    itemBuilder: (context, index) {
                      final category = categories[index];

                      return _CategoryItem(
                        category: category,
                        selected:
                            selectedCategoryId == category.id,
                        onTap: () {
                          onCategorySelected(category.id);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CategoryItem extends StatelessWidget {
  const _CategoryItem({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final dynamic category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),

        padding: const EdgeInsets.symmetric(
          horizontal: 6,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? colors.primary
                : colors.outlineVariant,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: selected
                    ? colors.primaryContainer
                    : colors.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getCategoryIcon(category.name),
                color: colors.primary,
                size: 22,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              category.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoreCategoryItem extends StatelessWidget {
  const _MoreCategoryItem({
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(

        padding: const EdgeInsets.symmetric(
          horizontal: 6,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colors.outlineVariant,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add_rounded,
                color: colors.primary,
                size: 24,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              'المزيد',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

IconData _getCategoryIcon(String name) {
  switch (name) {
    case 'طعام':
      return Icons.restaurant_rounded;

    case 'مواصلات':
      return Icons.directions_car_rounded;

    case 'تسوق':
      return Icons.shopping_bag_rounded;

    case 'إيجار':
      return Icons.home_rounded;

    case 'صحة':
      return Icons.health_and_safety_rounded;

    case 'تعليم':
      return Icons.school_rounded;

    case 'فواتير':
      return Icons.receipt_long_rounded;

    case 'ترفيه':
      return Icons.movie_rounded;

    case 'راتب':
      return Icons.payments_rounded;

    case 'مكافأة':
      return Icons.card_giftcard_rounded;

    case 'تحويل':
      return Icons.swap_horiz_rounded;

    case 'استثمار':
      return Icons.trending_up_rounded;

    default:
      return Icons.category_rounded;
  }
}