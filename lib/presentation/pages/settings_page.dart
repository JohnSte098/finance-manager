// lib/presentation/pages/settings_page.dart
import 'dart:io';
import 'package:excel/excel.dart' hide Border;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_utils.dart';
import 'package:local_auth/local_auth.dart';
import '../providers/category_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/transaction_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      backgroundColor: AppColors.bg0,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Text('Settings',
                  style: TextStyle(
                    fontFamily: 'Outfit', fontSize: 26,
                    fontWeight: FontWeight.w700, color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ),

            // Profile Section
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(
                child: _SectionCard(
                  title: 'User Data',
                  icon: Icons.person_rounded,
                  child: _SettingsRow(
                    icon: Icons.badge_rounded,
                    iconColor: AppColors.income,
                    label: 'Display Name',
                    subtitle: settings.userName,
                    onTap: () async {
                      final ctrl = TextEditingController(text: settings.userName);
                      final name = await showDialog<String>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: AppColors.bg2,
                          title: const Text('Enter your name', style: TextStyle(fontFamily: 'Outfit', color: AppColors.textPrimary)),
                          content: TextField(
                            controller: ctrl,
                            autofocus: true,
                            style: const TextStyle(color: AppColors.textPrimary, fontFamily: 'Outfit'),
                            decoration: const InputDecoration(labelText: 'Name'),
                          ),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(fontFamily: 'Outfit', color: AppColors.textSecondary))),
                            TextButton(onPressed: () => Navigator.pop(ctx, ctrl.text.trim()), child: const Text('Save', style: TextStyle(fontFamily: 'Outfit', color: AppColors.accent))),
                          ],
                        ),
                      );
                      if (name != null && name.isNotEmpty) {
                        settings.setUserName(name);
                      }
                    },
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Currency Section
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(
                child: _SectionCard(
                  title: 'Currency',
                  icon: Icons.currency_exchange_rounded,
                  child: Row(
                    children: CurrencyUtils.names.keys.map((code) {
                      final sel = settings.currency == code;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => settings.setCurrency(code),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: sel ? AppColors.accent.withValues(alpha: 0.2) : AppColors.bg3,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: sel ? AppColors.accent : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(CurrencyUtils.symbol(code),
                                  style: TextStyle(
                                    fontFamily: 'Outfit', fontSize: 18, fontWeight: FontWeight.w700,
                                    color: sel ? AppColors.accentLight : AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(code,
                                  style: TextStyle(
                                    fontFamily: 'Outfit', fontSize: 12,
                                    color: sel ? AppColors.accent : AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Security
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(
                child: _SectionCard(
                  title: 'Security',
                  icon: Icons.shield_rounded,
                  child: _SettingsRow(
                    icon: Icons.fingerprint_rounded,
                    iconColor: AppColors.cyan,
                    label: 'Biometric Lock',
                    subtitle: 'Lock app with Face ID / Fingerprint',
                    trailing: Switch.adaptive(
                      value: settings.biometricEnabled,
                      activeColor: AppColors.accent,
                      onChanged: (val) async {
                        if (val) {
                          final auth = LocalAuthentication();
                          final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
                          final bool canAuthenticate = canAuthenticateWithBiometrics || await auth.isDeviceSupported();
                          
                          if (!canAuthenticate) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Your device does not support biometric authentication.'),
                                  backgroundColor: AppColors.expense,
                                ),
                              );
                            }
                            return;
                          }
                          
                          // Test the authentication right away to verify it works
                          try {
                            final didAuthenticate = await auth.authenticate(
                              localizedReason: 'Please authenticate to enable biometric lock',
                              options: const AuthenticationOptions(biometricOnly: false),
                            );
                            if (didAuthenticate) {
                              settings.setBiometric(true);
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to enable biometrics: $e'),
                                  backgroundColor: AppColors.expense,
                                ),
                              );
                            }
                          }
                        } else {
                          settings.setBiometric(false);
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Data & Export
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(
                child: _SectionCard(
                  title: 'Data',
                  icon: Icons.storage_rounded,
                  child: Column(
                    children: [
                      _SettingsRow(
                        icon: Icons.download_rounded,
                        iconColor: AppColors.income,
                        label: 'Export to Excel',
                        subtitle: 'Download all transactions as .xlsx',
                        onTap: () => _exportExcel(context),
                      ),
                      const SizedBox(height: 4),
                      _SettingsRow(
                        icon: Icons.table_chart_rounded,
                        iconColor: AppColors.cyan,
                        label: 'Export to CSV',
                        subtitle: 'Download all transactions as .csv',
                        onTap: () => _exportCSV(context),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Categories shortcut
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(
                child: _SectionCard(
                  title: 'Categories',
                  icon: Icons.category_rounded,
                  child: _SettingsRow(
                    icon: Icons.edit_rounded,
                    iconColor: AppColors.accent,
                    label: 'Manage Categories',
                    subtitle: 'Add, edit or remove custom categories',
                    onTap: () => Navigator.pushNamed(context, '/categories'),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // App info
            const SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(
                child: _SectionCard(
                  title: 'About',
                  icon: Icons.info_outline_rounded,
                  child: Column(
                    children: [
                      _SettingsRow(
                        icon: Icons.monetization_on_rounded,
                        iconColor: AppColors.warning,
                        label: 'Money Tracker',
                        subtitle: 'Version 1.0.0',
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Branded Logo Footer
            SliverToBoxAdapter(
              child: Center(
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.bg2,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.bg3),
                      ),
                      padding: const EdgeInsets.all(10),
                      child: Image.asset('assets/logo.png', fit: BoxFit.contain),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'MONEY TRACKER',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textMuted.withValues(alpha: 0.5),
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),

            // Stats footer
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(
                child: Consumer<TransactionProvider>(
                  builder: (_, tx, __) => Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.bg1,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _FooterStat('Transactions', '${tx.all.length}'),
                        _vDivider(),
                        _FooterStat('Expenses', '${tx.expenses.length}'),
                        _vDivider(),
                        _FooterStat('Incomes', '${tx.income.length}'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _vDivider() => Container(width: 1, height: 30, color: AppColors.bg3);

  Future<void> _exportExcel(BuildContext context) async {
    try {
      final tx   = context.read<TransactionProvider>();
      final cats = context.read<CategoryProvider>();
      final cur  = context.read<SettingsProvider>().currency;
      final data = tx.exportData(cur);

      final excel = Excel.createExcel();
      final sheet = excel['Transactions'];

      // Header
      final headers = ['Date', 'Type', 'Category', 'Description', 'Note', 'Amount', 'Currency'];
      for (var i = 0; i < headers.length; i++) {
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
          .value = TextCellValue(headers[i]);
      }

      // Resolve category names
      for (var r = 0; r < data.length; r++) {
        final row = data[r];
        final catName = cats.findById(row['Category'] as String)?.name ?? row['Category'];
        final values = [
          row['Date'], row['Type'], catName, row['Description'],
          row['Note'], row['Amount'], row['Currency'],
        ];
        for (var c = 0; c < values.length; c++) {
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: r + 1))
            .value = TextCellValue(values[c].toString());
        }
      }

      final dir  = await getTemporaryDirectory();
      final file = File('${dir.path}/money_manager_export.xlsx');
      final bytes = excel.encode();
      if (bytes != null) {
        await file.writeAsBytes(bytes);
        await Share.shareXFiles([XFile(file.path)], text: 'Money Manager Export');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Export failed: $e'),
          backgroundColor: AppColors.expense,
        ));
      }
    }
  }

  Future<void> _exportCSV(BuildContext context) async {
    try {
      final tx   = context.read<TransactionProvider>();
      final cats = context.read<CategoryProvider>();
      final cur  = context.read<SettingsProvider>().currency;
      final data = tx.exportData(cur);

      const header = 'Date,Type,Category,Description,Note,Amount,Currency\n';
      final rows   = data.map((row) {
        final catName = cats.findById(row['Category'] as String)?.name ?? row['Category'];
        return '"${row['Date']}","${row['Type']}","$catName","${row['Description']}",'
               '"${row['Note']}","${row['Amount']}","${row['Currency']}"';
      }).join('\n');

      final dir  = await getTemporaryDirectory();
      final file = File('${dir.path}/money_manager_export.csv');
      await file.writeAsString('$header$rows');
      await Share.shareXFiles([XFile(file.path)], text: 'Money Manager CSV Export');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Export failed: $e'),
          backgroundColor: AppColors.expense,
        ));
      }
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bg1,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.bg3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Icon(icon, size: 16, color: AppColors.accent),
                const SizedBox(width: 8),
                Text(title,
                  style: const TextStyle(
                    fontFamily: 'Outfit', fontWeight: FontWeight.w600,
                    fontSize: 13, color: AppColors.accent,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          Container(height: 1, color: AppColors.bg3),
          Padding(padding: const EdgeInsets.all(12), child: child),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                    style: const TextStyle(
                      fontFamily: 'Outfit', fontWeight: FontWeight.w500,
                      fontSize: 14, color: AppColors.textPrimary,
                    ),
                  ),
                  Text(subtitle,
                    style: const TextStyle(
                      fontFamily: 'Outfit', fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            trailing ?? (onTap != null
              ? const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 20)
              : const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }
}

class _FooterStat extends StatelessWidget {
  final String label;
  final String value;
  const _FooterStat(this.label, this.value);

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(value,
        style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w700,
          fontSize: 18, color: AppColors.textPrimary)),
      Text(label,
        style: const TextStyle(fontFamily: 'Outfit', fontSize: 11, color: AppColors.textMuted)),
    ],
  );
}

