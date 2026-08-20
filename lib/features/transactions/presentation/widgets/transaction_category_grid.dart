import 'package:flutter/material.dart';

import '../../../../core/database/app_database.dart';
import '../../../../shared/utils/category_icon_mapper.dart';

class TransactionCategoryGrid extends StatefulWidget {
  const TransactionCategoryGrid({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
    this.onAddCategoryPressed,
  });

  final List<Category> categories;
  final int? selectedCategoryId;
  final ValueChanged<int> onCategorySelected;
  final VoidCallback? onAddCategoryPressed;

  static const int _visibleCount = 7;

  @override
  State<TransactionCategoryGrid> createState() => _TransactionCategoryGridState();
}

class _TransactionCategoryGridState extends State<TransactionCategoryGrid> {
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    if (widget.categories.isEmpty) {
      return const SizedBox.shrink();
    }

    final visibleCategories = _showAll
        ? widget.categories
        : widget.categories.take(TransactionCategoryGrid._visibleCount).toList();

    final items = <Widget>[
      ...visibleCategories.map(
        (category) => _CategoryItem(
          category: category,
          selected: widget.selectedCategoryId == category.id,
          onTap: () => widget.onCategorySelected(category.id),
        ),
      ),
    ];

    if (!_showAll && widget.categories.length > TransactionCategoryGrid._visibleCount) {
      items.add(
        _MoreCategoryItem(
          onTap: () => setState(() => _showAll = true),
        ),
      );
    }

    items.add(
      _AddCategoryItem(
        onTap: widget.onAddCategoryPressed ?? () {},
      ),
    );

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
}

class _CategoryItem extends StatelessWidget {
  const _CategoryItem({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final Category category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final categoryColor = Color(category.color);

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
                    : categoryColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                categoryIconFromKey(category.icon),
                color: categoryColor,
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
                Icons.more_horiz_rounded,
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

class _AddCategoryItem extends StatelessWidget {
  const _AddCategoryItem({required this.onTap});

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
                color: colors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add_rounded,
                color: colors.onPrimaryContainer,
                size: 24,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'إضافة',
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