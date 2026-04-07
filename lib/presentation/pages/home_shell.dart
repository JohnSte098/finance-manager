// lib/presentation/pages/home_shell.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';
import '../pages/add_transaction_sheet.dart';
import '../pages/analytics_page.dart';
import '../pages/budget_page.dart';
import '../pages/dashboard_page.dart';
import '../pages/transactions_page.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    if (index == 2) {
      _openAddSheet();
      return;
    }
    HapticFeedback.selectionClick();
    setState(() => _currentIndex = index);
  }

  void _openAddSheet() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: const AddTransactionSheet(),
      ),
    );
  }

  /// Map nav index → page index (skipping the FAB at nav position 2)
  /// Nav:   0=Home  1=Txns  2=FAB  3=Analytics  4=Budget
  /// Pages: 0=Home  1=Txns         2=Analytics  3=Budget
  int get _pageIndex {
    if (_currentIndex < 2) return _currentIndex;
    if (_currentIndex > 2) return _currentIndex - 1;
    return 0; // FAB tap – handled above, won't reach here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg0,
      body: IndexedStack(
        index: _pageIndex,
        children: const [
          DashboardPage(),
          TransactionsPage(),
          AnalyticsPage(),
          BudgetPage(),
        ],
      ),
      bottomNavigationBar: _buildNavBar(),
    );
  }

  Widget _buildNavBar() {
    // Custom bottom nav with a center FAB slot
    return Container(
      height: 72 + MediaQuery.of(context).padding.bottom,
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: AppColors.bg1,
        border: const Border(top: BorderSide(color: AppColors.bg3, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          _NavItem(icon: Icons.home_rounded,      label: 'Home',      index: 0, current: _currentIndex, onTap: _onTabTapped),
          _NavItem(icon: Icons.list_alt_rounded,  label: 'Txns',      index: 1, current: _currentIndex, onTap: _onTabTapped),

          // Center FAB
          Expanded(
            child: GestureDetector(
              onTap: _openAddSheet,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 52, height: 52,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.accentLight, AppColors.accent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withValues(alpha: 0.5),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
                  ),
                ],
              ),
            ),
          ),

          _NavItem(icon: Icons.bar_chart_rounded, label: 'Analytics', index: 3, current: _currentIndex, onTap: _onTabTapped),
          _NavItem(icon: Icons.pie_chart_rounded, label: 'Budget',    index: 4, current: _currentIndex, onTap: _onTabTapped),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int current;
  final void Function(int) onTap;

  const _NavItem({
    required this.icon, required this.label,
    required this.index, required this.current, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selected = current == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: selected ? AppColors.accent.withValues(alpha: 0.15) : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon,
                size: 22,
                color: selected ? AppColors.accentLight : AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 2),
            Text(label,
              style: TextStyle(
                fontFamily: 'Outfit', fontSize: 10,
                color: selected ? AppColors.accentLight : AppColors.textMuted,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
