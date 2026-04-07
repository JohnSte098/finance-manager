// lib/presentation/pages/transactions_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/default_categories.dart';
import '../../core/theme/app_theme.dart';
import '../providers/category_provider.dart';
import '../providers/transaction_provider.dart';
import '../widgets/transaction_tile.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});
  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  final _searchCtrl = TextEditingController();
  String _query      = '';
  String? _catFilter;
  bool?   _typeFilter; // true=expense, false=income, null=all

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tx   = context.watch<TransactionProvider>();
    final cats = context.watch<CategoryProvider>();
    final results = tx.search(_query, categoryId: _catFilter, isExpense: _typeFilter);

    return Scaffold(
      backgroundColor: AppColors.bg0,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  const Text('Transactions',
                    style: TextStyle(
                      fontFamily: 'Outfit', fontSize: 26,
                      fontWeight: FontWeight.w700, color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const Spacer(),
                  Text('${results.length} items',
                    style: const TextStyle(
                      fontFamily: 'Outfit', fontSize: 13,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _query = v),
                style: const TextStyle(color: AppColors.textPrimary, fontFamily: 'Outfit'),
                decoration: InputDecoration(
                  hintText: 'Search transactions…',
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted, size: 20),
                  suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, color: AppColors.textMuted, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Filter chips row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _FilterChip(
                    label: 'All',
                    selected: _typeFilter == null && _catFilter == null,
                    color: AppColors.accent,
                    onTap: () => setState(() { _typeFilter = null; _catFilter = null; }),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Expense',
                    selected: _typeFilter == true,
                    color: AppColors.expense,
                    onTap: () => setState(() => _typeFilter = _typeFilter == true ? null : true),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Income',
                    selected: _typeFilter == false,
                    color: AppColors.income,
                    onTap: () => setState(() => _typeFilter = _typeFilter == false ? null : false),
                  ),
                  const SizedBox(width: 8),
                  const _Divider(),
                  const SizedBox(width: 8),
                  ...cats.all.map((cat) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _FilterChip(
                      label: cat.name,
                      icon: CategoryIcons.iconFor(cat.iconName),
                      selected: _catFilter == cat.id,
                      color: cat.color,
                      onTap: () => setState(() => _catFilter = _catFilter == cat.id ? null : cat.id),
                    ),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // List
            Expanded(
              child: results.isEmpty
                ? const _EmptySearch()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: results.length,
                    itemBuilder: (_, i) {
                      final t = results[i];
                      return TransactionTile(
                        tx: t,
                        onDelete: () => context.read<TransactionProvider>().deleteTransaction(t.id),
                      );
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;
  final IconData? icon;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.2) : AppColors.bg2,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color : AppColors.bg3,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 12, color: selected ? color : AppColors.textMuted),
              const SizedBox(width: 5),
            ],
            Text(label,
              style: TextStyle(
                fontFamily: 'Outfit', fontSize: 12,
                color: selected ? color : AppColors.textSecondary,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) => Container(
    width: 1, height: 20, color: AppColors.bg3,
  );
}

class _EmptySearch extends StatelessWidget {
  const _EmptySearch();
  @override
  Widget build(BuildContext context) => const Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.search_off_rounded, color: AppColors.textMuted, size: 48),
        SizedBox(height: 12),
        Text('No transactions found',
          style: TextStyle(fontFamily: 'Outfit', fontSize: 15, color: AppColors.textSecondary)),
        SizedBox(height: 4),
        Text('Try different keywords or filters',
          style: TextStyle(fontFamily: 'Outfit', fontSize: 12, color: AppColors.textMuted)),
      ],
    ),
  );
}
