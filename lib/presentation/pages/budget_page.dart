// lib/presentation/pages/budget_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/default_categories.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_utils.dart';
import '../../data/models/budget_model.dart';
import '../../data/models/category_model.dart';
import '../providers/budget_provider.dart';
import '../providers/category_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/transaction_provider.dart';

class BudgetPage extends StatelessWidget {
  const BudgetPage({super.key});

  @override
  Widget build(BuildContext context) {
    final budget   = context.watch<BudgetProvider>();
    final cats     = context.watch<CategoryProvider>();
    final tx       = context.watch<TransactionProvider>();
    final cur      = context.watch<SettingsProvider>().currency;
    final spent    = tx.monthlyExpenseByCategory;
    final expCats  = cats.expenseCategories;
    final now      = DateTime.now();

    return Scaffold(
      backgroundColor: AppColors.bg0,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Budget',
                      style: TextStyle(
                        fontFamily: 'Outfit', fontSize: 26,
                        fontWeight: FontWeight.w700, color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text('${_monthName(now.month)} ${now.year}',
                      style: const TextStyle(
                        fontFamily: 'Outfit', fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Summary card
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              sliver: SliverToBoxAdapter(
                child: _BudgetSummaryCard(budget: budget, spent: spent, cur: cur),
              ),
            ),

            // Category budgets
            const SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(
                child: Text('Category Budgets',
                  style: TextStyle(
                    fontFamily: 'Outfit', fontWeight: FontWeight.w700,
                    fontSize: 18, color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) {
                    final cat = expCats[i];
                    final bud = budget.getBudget(cat.id);
                    final s   = spent[cat.id] ?? 0.0;
                    return _BudgetCategoryCard(
                      cat: cat,
                      budget: bud,
                      spent: s,
                      currency: cur,
                      onSet: (limit) => budget.setBudget(categoryId: cat.id, limit: limit),
                      onRemove: () => budget.removeBudget(cat.id),
                    );
                  },
                  childCount: expCats.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  String _monthName(int m) {
    const names = ['','January','February','March','April','May','June',
                    'July','August','September','October','November','December'];
    return names[m];
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _BudgetSummaryCard extends StatelessWidget {
  final BudgetProvider budget;
  final Map<String, double> spent;
  final String cur;

  const _BudgetSummaryCard({required this.budget, required this.spent, required this.cur});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final allBudgets = budget.all.where((b) => b.month == now.month && b.year == now.year).toList();
    final totalLimit = allBudgets.fold(0.0, (s, b) => s + b.limitAmount);
    final totalSpent = allBudgets.fold(0.0, (s, b) => s + (spent[b.categoryId] ?? 0));
    final pct = totalLimit > 0 ? (totalSpent / totalLimit).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.accent.withValues(alpha: 0.15), AppColors.bg2],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Total Budget Usage',
                style: TextStyle(fontFamily: 'Outfit', fontSize: 14, color: AppColors.textSecondary)),
              const Spacer(),
              Text('${(pct * 100).toInt()}%',
                style: TextStyle(
                  fontFamily: 'Outfit', fontWeight: FontWeight.w700, fontSize: 15,
                  color: pct >= 1 ? AppColors.expense : pct >= 0.8 ? AppColors.warning : AppColors.income,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 8,
              backgroundColor: AppColors.bg3,
              valueColor: AlwaysStoppedAnimation(
                pct >= 1 ? AppColors.expense : pct >= 0.8 ? AppColors.warning : AppColors.income,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _statChip('Spent', CurrencyUtils.format(totalSpent, cur), AppColors.expense),
              const SizedBox(width: 12),
              _statChip('Budget', CurrencyUtils.format(totalLimit, cur), AppColors.accent),
              const SizedBox(width: 12),
              _statChip('Remaining', CurrencyUtils.format((totalLimit - totalSpent).clamp(0, double.infinity), cur), AppColors.income),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statChip(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontFamily: 'Outfit', fontSize: 11, color: AppColors.textMuted)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w700, fontSize: 13, color: color)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _BudgetCategoryCard extends StatelessWidget {
  final CategoryModel cat;
  final BudgetModel?  budget;
  final double        spent;
  final String        currency;
  final Future<void> Function(double) onSet;
  final VoidCallback  onRemove;

  const _BudgetCategoryCard({
    required this.cat, required this.budget,
    required this.spent, required this.currency,
    required this.onSet, required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final hasBudget = budget != null;
    final pct       = hasBudget ? (spent / budget!.limitAmount).clamp(0.0, 1.0) : 0.0;
    final statusColor = pct >= 1 ? AppColors.expense : pct >= 0.8 ? AppColors.warning : AppColors.income;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bg1,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasBudget && pct >= 0.8 ? statusColor.withValues(alpha: 0.3) : AppColors.bg3,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: cat.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(CategoryIcons.iconFor(cat.iconName), color: cat.color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(cat.name,
                      style: const TextStyle(
                        fontFamily: 'Outfit', fontWeight: FontWeight.w600,
                        fontSize: 14, color: AppColors.textPrimary,
                      ),
                    ),
                    if (hasBudget)
                      Text(
                        '${CurrencyUtils.format(spent, currency)} / ${CurrencyUtils.format(budget!.limitAmount, currency)}',
                        style: TextStyle(fontFamily: 'Outfit', fontSize: 11, color: statusColor),
                      )
                    else
                      const Text('No budget set',
                        style: TextStyle(fontFamily: 'Outfit', fontSize: 11, color: AppColors.textMuted)),
                  ],
                ),
              ),
              // Action button
              GestureDetector(
                onTap: () => _showBudgetDialog(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: hasBudget ? AppColors.bg3 : AppColors.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: hasBudget ? Colors.transparent : AppColors.accent.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    hasBudget ? 'Edit' : 'Set',
                    style: TextStyle(
                      fontFamily: 'Outfit', fontSize: 12, fontWeight: FontWeight.w600,
                      color: hasBudget ? AppColors.textSecondary : AppColors.accentLight,
                    ),
                  ),
                ),
              ),
              if (hasBudget) ...[
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: onRemove,
                  child: Container(
                    width: 30, height: 30,
                    decoration: BoxDecoration(
                      color: AppColors.expense.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.remove_rounded, color: AppColors.expense, size: 16),
                  ),
                ),
              ],
            ],
          ),
          if (hasBudget) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: pct,
                minHeight: 5,
                backgroundColor: AppColors.bg3,
                valueColor: AlwaysStoppedAnimation(statusColor),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showBudgetDialog(BuildContext context) {
    final ctrl = TextEditingController(
      text: budget != null ? budget!.limitAmount.toStringAsFixed(0) : '',
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bg2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Budget for ${cat.name}',
          style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
          style: const TextStyle(color: AppColors.textPrimary, fontFamily: 'Outfit', fontSize: 24, fontWeight: FontWeight.w700),
          decoration: InputDecoration(
            prefixText: '${CurrencyUtils.symbol(currency)}  ',
            prefixStyle: const TextStyle(color: AppColors.textSecondary, fontFamily: 'Outfit', fontSize: 20),
            hintText: '0',
            hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 24),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(fontFamily: 'Outfit', color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              final val = double.tryParse(ctrl.text.trim());
              if (val != null && val > 0) {
                await onSet(val);
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('Save', style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

