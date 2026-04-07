// lib/presentation/widgets/transaction_tile.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/default_categories.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_utils.dart';
import '../../data/models/transaction_model.dart';
import '../providers/category_provider.dart';
import '../providers/settings_provider.dart';

class TransactionTile extends StatelessWidget {
  final TransactionModel tx;
  final VoidCallback? onDelete;

  const TransactionTile({super.key, required this.tx, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final catProvider  = context.watch<CategoryProvider>();
    final settings     = context.watch<SettingsProvider>();
    final cat          = catProvider.findById(tx.categoryId);
    final catColor     = cat?.color ?? AppColors.textMuted;
    final catIcon      = CategoryIcons.iconFor(cat?.iconName ?? 'other');
    final catName      = cat?.name ?? tx.categoryId;
    final symbol       = CurrencyUtils.format(tx.amount, settings.currency);
    final isExp        = tx.isExpense;

    return Dismissible(
      key: Key(tx.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.expense.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: AppColors.expense, size: 22),
      ),
      onDismissed: (_) => onDelete?.call(),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.bg1,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.bg3, width: 1),
        ),
        child: Row(
          children: [
            // Category Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: catColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(catIcon, color: catColor, size: 22),
            ),
            const SizedBox(width: 14),
            // Title & category
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tx.title,
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Text(catName,
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 11,
                          color: catColor.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (tx.isRecurring) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('Recurring',
                            style: TextStyle(fontSize: 9, color: AppColors.accentLight, fontFamily: 'Outfit'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // Amount & date
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isExp ? '-' : '+'}$symbol',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: isExp ? AppColors.expense : AppColors.income,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _formatDate(tx.date),
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day} ${months[d.month - 1]}';
  }
}
