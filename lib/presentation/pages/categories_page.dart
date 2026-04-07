// lib/presentation/pages/categories_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/default_categories.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/category_model.dart';
import '../providers/category_provider.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});
  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg0,
      appBar: AppBar(
        title: const Text('Categories'),
        bottom: TabBar(
          controller: _tab,
          indicatorColor: AppColors.accent,
          labelColor: AppColors.accentLight,
          unselectedLabelColor: AppColors.textMuted,
          labelStyle: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w600),
          tabs: const [Tab(text: 'Expense'), Tab(text: 'Income')],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCategoryDialog(context, isExpense: _tab.index == 0),
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded),
      ),
      body: Consumer<CategoryProvider>(
        builder: (ctx, prov, _) {
          return TabBarView(
            controller: _tab,
            children: [
              _buildList(context, prov.expenseCategories, prov, isExpense: true),
              _buildList(context, prov.incomeCategories, prov, isExpense: false),
            ],
          );
        },
      ),
    );
  }

  Widget _buildList(BuildContext context, List<CategoryModel> cats, CategoryProvider prov, {required bool isExpense}) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: cats.length,
      itemBuilder: (_, i) {
        final cat = cats[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.bg1,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.bg3),
          ),
          child: Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: cat.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(CategoryIcons.iconFor(cat.iconName), color: cat.color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(cat.name,
                      style: const TextStyle(
                        fontFamily: 'Outfit', fontWeight: FontWeight.w600,
                        fontSize: 15, color: AppColors.textPrimary,
                      ),
                    ),
                    Text(cat.isCustom ? 'Custom' : 'Default',
                      style: TextStyle(
                        fontFamily: 'Outfit', fontSize: 11,
                        color: cat.isCustom ? AppColors.accentLight : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              if (cat.isCustom) ...[
                IconButton(
                  icon: const Icon(Icons.edit_rounded, size: 18, color: AppColors.textSecondary),
                  onPressed: () => _showCategoryDialog(context, existing: cat, isExpense: cat.isExpenseCategory),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.expense),
                  onPressed: () => _confirmDelete(context, cat, prov),
                ),
              ] else
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(Icons.lock_outline_rounded, size: 16, color: AppColors.textMuted),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, CategoryModel cat, CategoryProvider prov) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bg2,
        title: const Text('Delete Category', style: TextStyle(fontFamily: 'Outfit', color: AppColors.textPrimary)),
        content: Text('Delete "${cat.name}"? Existing transactions will keep this category ID.',
          style: const TextStyle(fontFamily: 'Outfit', color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(fontFamily: 'Outfit', color: AppColors.textSecondary))),
          TextButton(onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(fontFamily: 'Outfit', color: AppColors.expense))),
        ],
      ),
    );
    if (confirmed == true) await prov.deleteCategory(cat.id);
  }

  void _showCategoryDialog(BuildContext context, {CategoryModel? existing, required bool isExpense}) {
    showDialog(
      context: context,
      builder: (ctx) => _CategoryFormDialog(
        existing: existing,
        initialIsExpense: isExpense,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Category Form Dialog
// ─────────────────────────────────────────────────────────────────────────────
class _CategoryFormDialog extends StatefulWidget {
  final CategoryModel? existing;
  final bool initialIsExpense;

  const _CategoryFormDialog({this.existing, required this.initialIsExpense});

  @override
  State<_CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends State<_CategoryFormDialog> {
  final _nameCtrl = TextEditingController();
  Color  _color    = AppColors.categoryPalette[0];
  String _icon     = 'custom';
  bool   _isExpense = true;

  @override
  void initState() {
    super.initState();
    _isExpense = widget.initialIsExpense;
    if (widget.existing != null) {
      final e = widget.existing!;
      _nameCtrl.text = e.name;
      _color  = e.color;
      _icon   = e.iconName;
      _isExpense = e.isExpenseCategory;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return AlertDialog(
      backgroundColor: AppColors.bg2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(isEdit ? 'Edit Category' : 'New Category',
        style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Live preview
            Center(
              child: Container(
                width: 70, height: 70,
                decoration: BoxDecoration(
                  color: _color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: _color.withValues(alpha: 0.4), width: 2),
                ),
                child: Icon(CategoryIcons.iconFor(_icon), color: _color, size: 34),
              ),
            ),
            const SizedBox(height: 16),

            // Name
            TextField(
              controller: _nameCtrl,
              style: const TextStyle(color: AppColors.textPrimary, fontFamily: 'Outfit'),
              decoration: const InputDecoration(labelText: 'Category Name'),
            ),
            const SizedBox(height: 16),

            // Type toggle
            Row(
              children: [
                const Text('Type:', style: TextStyle(color: AppColors.textSecondary, fontFamily: 'Outfit', fontSize: 13)),
                const SizedBox(width: 12),
                _TypeChip(label: 'Expense', selected: _isExpense, color: AppColors.expense,
                  onTap: () => setState(() => _isExpense = true)),
                const SizedBox(width: 8),
                _TypeChip(label: 'Income', selected: !_isExpense, color: AppColors.income,
                  onTap: () => setState(() => _isExpense = false)),
              ],
            ),
            const SizedBox(height: 16),

            // Color picker
            const Text('Color', style: TextStyle(color: AppColors.textSecondary, fontFamily: 'Outfit', fontSize: 13)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: AppColors.categoryPalette.map((c) {
                return GestureDetector(
                  onTap: () => setState(() => _color = c),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _color == c ? Colors.white : Colors.transparent,
                        width: 2.5,
                      ),
                    ),
                    child: _color == c
                        ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Icon picker
            const Text('Icon', style: TextStyle(color: AppColors.textSecondary, fontFamily: 'Outfit', fontSize: 13)),
            const SizedBox(height: 8),
            SizedBox(
              height: 130,
              child: GridView.count(
                crossAxisCount: 6,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                children: CategoryIcons.selectableIcons.map((name) {
                  final selected = _icon == name;
                  return GestureDetector(
                    onTap: () => setState(() => _icon = name),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      decoration: BoxDecoration(
                        color: selected ? _color.withValues(alpha: 0.25) : AppColors.bg3,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: selected ? _color : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        CategoryIcons.iconFor(name),
                        color: selected ? _color : AppColors.textMuted,
                        size: 20,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(fontFamily: 'Outfit', color: AppColors.textSecondary)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () async {
            if (_nameCtrl.text.trim().isEmpty) return;
            final prov = context.read<CategoryProvider>();
            if (widget.existing != null) {
              await prov.editCustomCategory(
                id: widget.existing!.id,
                name: _nameCtrl.text.trim(),
                color: _color, iconName: _icon, isExpense: _isExpense,
              );
            } else {
              await prov.addCustomCategory(
                name: _nameCtrl.text.trim(),
                color: _color, iconName: _icon, isExpense: _isExpense,
              );
            }
            if (context.mounted) Navigator.pop(context);
          },
          child: Text(widget.existing != null ? 'Save' : 'Create',
            style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _TypeChip({required this.label, required this.selected, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.2) : AppColors.bg3,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selected ? color : Colors.transparent, width: 1.5),
        ),
        child: Text(label,
          style: TextStyle(
            fontFamily: 'Outfit', fontSize: 12,
            color: selected ? color : AppColors.textSecondary,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

