// lib/presentation/pages/dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_utils.dart';
import '../providers/budget_provider.dart';
import '../providers/category_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/transaction_provider.dart';
import '../widgets/glass_card.dart';
import '../widgets/transaction_tile.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tx       = context.watch<TransactionProvider>();
    final settings = context.watch<SettingsProvider>();
    final budget   = context.watch<BudgetProvider>();
    final cur      = settings.currency;

    // Check budget warnings
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final warnings = budget.checkWarnings(tx.monthlyExpenseByCategory);
      if (warnings.isNotEmpty && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('âš ï¸ Budget at 80% in ${warnings.length} category(ies)!'),
            backgroundColor: AppColors.warning,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.bg0,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(child: _buildHeader(context, cur, tx, settings)),

            // Balance Card
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(
                child: _buildBalanceCard(context, tx, cur)
                    .animate().fadeIn(duration: 600.ms).slideY(begin: 0.15),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // Income / Expense summary
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(
                child: _buildSummaryRow(tx, cur)
                    .animate().fadeIn(duration: 700.ms, delay: 100.ms),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Budget warnings
            if (budget.all.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverToBoxAdapter(
                  child: _buildBudgetWarnings(context, budget, tx, cur),
                ),
              ),

            // Recent Transactions header
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(child: _sectionHeader('Recent Transactions', context)),
            ),

            // Transactions list
            tx.all.isEmpty
                ? const SliverToBoxAdapter(child: _EmptyState())
                : SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) {
                          final t = tx.all[i];
                          return TransactionTile(
                            tx: t,
                            onDelete: () => context.read<TransactionProvider>().deleteTransaction(t.id),
                          ).animate().fadeIn(delay: (50 * i).ms).slideX(begin: 0.05);
                        },
                        childCount: tx.all.length > 20 ? 20 : tx.all.length,
                      ),
                    ),
                  ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String cur, TransactionProvider tx, SettingsProvider settings) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: AppColors.bg2,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.bg3),
            ),
            padding: const EdgeInsets.all(6),
            child: Image.asset('assets/logo.png', fit: BoxFit.contain),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${_greeting()} ${settings.userName}',
                  style: const TextStyle(
                    fontFamily: 'Outfit', fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Text('Dashboard',
                  style: TextStyle(
                    fontFamily: 'Outfit', fontSize: 26,
                    fontWeight: FontWeight.w700, color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          // Currency badge
          Consumer<SettingsProvider>(
            builder: (_, s, __) => Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.bg2,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.bg3),
              ),
              child: Text(s.currency,
                style: const TextStyle(
                  fontFamily: 'Outfit', fontWeight: FontWeight.w700,
                  color: AppColors.accent, fontSize: 13,
                ),
              ),
            ),
          ),
          // Settings button
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/settings'),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.bg2,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.bg3),
               ),
              child: const Icon(Icons.settings_rounded, color: AppColors.textSecondary, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context, TransactionProvider tx, String cur) {
    return GlassCard(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF1E1040), Color(0xFF0A1628)],
      ),
      borderColor: AppColors.accent.withValues(alpha: 0.25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Total Balance',
            style: TextStyle(
              fontFamily: 'Outfit', fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            CurrencyUtils.format(tx.balance, cur),
            style: const TextStyle(
              fontFamily: 'Outfit', fontSize: 40,
              fontWeight: FontWeight.w700, color: AppColors.textPrimary,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            tx.balance >= 0 ? 'â–² Looking good!' : 'â–¼ Review expenses',
            style: TextStyle(
              fontFamily: 'Outfit', fontSize: 12,
              color: tx.balance >= 0 ? AppColors.income : AppColors.expense,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.06),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _miniStat('Monthly Income', CurrencyUtils.format(tx.monthlyIncome, cur), AppColors.income, Icons.arrow_downward_rounded)),
              Container(width: 1, height: 40, color: Colors.white.withValues(alpha: 0.06)),
              Expanded(child: _miniStat('Monthly Spent', CurrencyUtils.format(tx.monthlyExpense, cur), AppColors.expense, Icons.arrow_upward_rounded)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value, Color color, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 20, height: 20,
                decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                child: Icon(icon, color: color, size: 12),
              ),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(fontFamily: 'Outfit', fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 4),
          Text(value,
            style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w700, fontSize: 16, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(TransactionProvider tx, String cur) {
    return Row(
      children: [
        Expanded(child: _summaryCard('Total Income', CurrencyUtils.format(tx.totalIncome, cur), AppColors.income)),
        const SizedBox(width: 12),
        Expanded(child: _summaryCard('Total Spent', CurrencyUtils.format(tx.totalExpense, cur), AppColors.expense)),
      ],
    );
  }

  Widget _summaryCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
            style: const TextStyle(fontFamily: 'Outfit', fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          Text(value,
            style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w700, fontSize: 20, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetWarnings(BuildContext context, BudgetProvider budget,
      TransactionProvider tx, String cur) {
    final spent = tx.monthlyExpenseByCategory;
    final overBudget = budget.all.where((b) {
      final s = spent[b.categoryId] ?? 0;
      return s / b.limitAmount >= 0.8;
    }).toList();

    if (overBudget.isEmpty) return const SizedBox.shrink();
    final cats = context.read<CategoryProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Budget Alerts', context),
        ...overBudget.map((b) {
          final s = spent[b.categoryId] ?? 0;
          final pct = (s / b.limitAmount).clamp(0.0, 1.0);
          final cat = cats.findById(b.categoryId);
          final catColor = cat?.color ?? AppColors.warning;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 16),
                    const SizedBox(width: 6),
                    Text(cat?.name ?? b.categoryId,
                      style: const TextStyle(
                        fontFamily: 'Outfit', fontWeight: FontWeight.w600,
                        fontSize: 13, color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    Text('${(pct * 100).toInt()}% used',
                      style: TextStyle(fontFamily: 'Outfit', fontSize: 12,
                        color: pct >= 1 ? AppColors.expense : AppColors.warning),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct,
                    backgroundColor: AppColors.bg3,
                    valueColor: AlwaysStoppedAnimation(
                      pct >= 1 ? AppColors.expense : AppColors.warning,
                    ),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${CurrencyUtils.format(s, cur)} / ${CurrencyUtils.format(b.limitAmount, cur)}',
                  style: const TextStyle(fontFamily: 'Outfit', fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _sectionHeader(String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 4),
      child: Row(
        children: [
          Text(title,
            style: const TextStyle(
              fontFamily: 'Outfit', fontWeight: FontWeight.w700,
              fontSize: 18, color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.receipt_long_rounded, color: AppColors.accent, size: 36),
          ),
          const SizedBox(height: 16),
          const Text('No transactions yet',
            style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w600, fontSize: 16, color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          const Text('Tap + to add your first transaction',
            style: TextStyle(fontFamily: 'Outfit', fontSize: 13, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}


