import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/database/app_database.dart';
import '../../../../shared/utils/category_icon_mapper.dart';
import '../../../transactions/models/transaction_type.dart';
import '../../../transactions/providers/category_repository_provider.dart';
import '../../../transactions/providers/transaction_categories_provider.dart';

class AddEditCategoryPage extends ConsumerStatefulWidget {
  const AddEditCategoryPage({super.key, this.category});

  final Category? category;

  bool get isEditing => category != null;

  @override
  ConsumerState<AddEditCategoryPage> createState() => _AddEditCategoryPageState();
}

class _AddEditCategoryPageState extends ConsumerState<AddEditCategoryPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;

  late String _selectedType;
  late int _selectedColor;
  late String _selectedIcon;

  static const List<int> _colorPalette = [
    0xFFE57373,
    0xFF64B5F6,
    0xFFFFB74D,
    0xFFBA68C8,
    0xFF4DB6AC,
    0xFF7986CB,
    0xFF66BB6A,
    0xFFFFCA28,
    0xFF26A69A,
    0xFF42A5F5,
    0xFF90A4AE,
    0xFF8D6E63,
  ];

  static const List<_IconOption> _iconOptions = [
    _IconOption('restaurant', Icons.restaurant_rounded),
    _IconOption('directions_car', Icons.directions_car_rounded),
    _IconOption('receipt_long', Icons.receipt_long_rounded),
    _IconOption('shopping_cart', Icons.shopping_cart_rounded),
    _IconOption('movie', Icons.movie_rounded),
    _IconOption('home', Icons.home_rounded),
    _IconOption('payments', Icons.payments_rounded),
    _IconOption('emoji_events', Icons.emoji_events_rounded),
    _IconOption('work', Icons.work_rounded),
    _IconOption('swap_horiz', Icons.swap_horiz_rounded),
    _IconOption('category', Icons.category_rounded),
    _IconOption('local_offer', Icons.local_offer_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _selectedType = widget.category?.type ?? 'expense';
    _selectedColor = widget.category?.color ?? _colorPalette.first;
    _selectedIcon = widget.category?.icon ?? _iconOptions.first.key;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();

    try {
      if (widget.isEditing) {
        await ref.read(categoryRepositoryProvider).updateCategory(
          categoryId: widget.category!.id,
          name: name,
          color: _selectedColor,
          icon: _selectedIcon,
        );
      } else {
        await ref.read(categoryRepositoryProvider).createCategory(
          name: name,
          type: _selectedType,
          color: _selectedColor,
          icon: _selectedIcon,
        );
      }

      ref.invalidate(allCategoriesProvider);
      ref.invalidate(transactionCategoriesProvider(TransactionType.expense));
      ref.invalidate(transactionCategoriesProvider(TransactionType.income));

      if (mounted) {
        context.pop();
      }
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final title = widget.isEditing ? 'تعديل التصنيف' : 'إضافة تصنيف';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: colors.surface,
        appBar: AppBar(
          title: Text(title),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.pop(),
          ),
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      color: Color(_selectedColor).withValues(alpha: 0.14),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      categoryIconFromKey(_selectedIcon),
                      size: 36,
                      color: Color(_selectedColor),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'اسم التصنيف',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _nameController,
                  textDirection: TextDirection.rtl,
                  decoration: InputDecoration(
                    hintText: 'مثال: الطعام',
                    hintStyle: TextStyle(color: colors.onSurfaceVariant),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'من فضلك أدخل اسم التصنيف';
                    }
                    if (value.trim().length < 2) {
                      return 'اسم التصنيف يجب أن يكون حرفين على الأقل';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                if (!widget.isEditing) ...[
                  _SectionHeader(title: 'نوع التصنيف'),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('مصروف'),
                          selected: _selectedType == 'expense',
                          onSelected: (_) => setState(() => _selectedType = 'expense'),
                          selectedColor: colors.primaryContainer,
                          showCheckmark: false,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('دخل'),
                          selected: _selectedType == 'income',
                          onSelected: (_) => setState(() => _selectedType = 'income'),
                          selectedColor: colors.primaryContainer,
                          showCheckmark: false,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
                _SectionHeader(title: 'الأيقونة'),
                const SizedBox(height: 10),
                GridView.count(
                  crossAxisCount: 4,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  children: _iconOptions.map((option) {
                    final selected = option.key == _selectedIcon;
                    return Material(
                      color: selected
                          ? colors.primaryContainer
                          : colors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => setState(() => _selectedIcon = option.key),
                        child: Center(
                          child: Icon(
                            option.icon,
                            color: selected ? colors.onPrimaryContainer : colors.onSurface,
                            size: 28,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                _SectionHeader(title: 'اللون'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _colorPalette.map((color) {
                    final selected = color == _selectedColor;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedColor = color),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Color(color),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selected ? colors.onSurface : Colors.transparent,
                            width: 3,
                          ),
                        ),
                        child: selected
                            ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: _saveCategory,
                  icon: const Icon(Icons.check_rounded),
                  label: Text(widget.isEditing ? 'حفظ التغييرات' : 'إضافة التصنيف'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _IconOption {
  const _IconOption(this.key, this.icon);

  final String key;
  final IconData icon;
}
