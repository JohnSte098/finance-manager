// lib/presentation/pages/analytics_page.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_utils.dart';
import '../providers/category_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/transaction_provider.dart';
import '../widgets/glass_card.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});
  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final tx     = context.watch<TransactionProvider>();
    final cats   = context.watch<CategoryProvider>();
    final cur    = context.watch<SettingsProvider>().currency;
    final expByCat = tx.monthlyExpenseByCategory;
    final weekly = tx.weeklyExpenses;

    return Scaffold(
      backgroundColor: AppColors.bg0,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Text('Analytics',
                  style: TextStyle(
                    fontFamily: 'Outfit', fontSize: 26,
                    fontWeight: FontWeight.w700, color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ),

            // Pie chart
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(
                child: GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('This Month Spending',
                        style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w600,
                          fontSize: 16, color: AppColors.textPrimary)),
                      const SizedBox(height: 4),
                      Text(CurrencyUtils.format(tx.monthlyExpense, cur),
                        style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w700,
                          fontSize: 28, color: AppColors.expense, letterSpacing: -0.5),
                      ),
                      const SizedBox(height: 20),
                      expByCat.isEmpty
                        ? const _NoPieData()
                        : SizedBox(
                            height: 220,
                            child: Row(
                              children: [
                                Expanded(flex: 3, child: _buildPieChart(expByCat, cats)
                                          .animate().scale(duration: 600.ms, curve: Curves.easeOutBack).fadeIn(duration: 600.ms)),
                                const SizedBox(width: 16),
                                Expanded(flex: 2, child: _buildLegend(expByCat, cats, cur)
                                          .animate().fadeIn(duration: 600.ms, delay: 200.ms).slideX(begin: 0.1)),
                              ],
                            ),
                          ),
                    ],
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Bar chart
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(
                child: GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Last 7 Days',
                        style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w600,
                          fontSize: 16, color: AppColors.textPrimary)),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 200,
                        child: _buildBarChart(weekly, cur)
                          .animate().slideY(begin: 0.15, duration: 800.ms, curve: Curves.easeOutQuart).fadeIn(duration: 800.ms),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Category breakdown list
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(
                child: GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Category Breakdown',
                        style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w600,
                          fontSize: 16, color: AppColors.textPrimary)),
                      const SizedBox(height: 16),
                      if (expByCat.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Text('No expense data yet',
                              style: TextStyle(fontFamily: 'Outfit', color: AppColors.textMuted)),
                          ),
                        )
                      else
                        ...expByCat.entries.map((e) {
                          final cat = cats.findById(e.key);
                          final pct = tx.monthlyExpense > 0 ? e.value / tx.monthlyExpense : 0.0;
                          final color = cat?.color ?? AppColors.textMuted;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 8, height: 8,
                                      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(cat?.name ?? e.key,
                                      style: const TextStyle(fontFamily: 'Outfit', fontSize: 13, color: AppColors.textPrimary)),
                                    const Spacer(),
                                    Text('${(pct * 100).toStringAsFixed(1)}%',
                                      style: TextStyle(fontFamily: 'Outfit', fontSize: 12, color: color, fontWeight: FontWeight.w600)),
                                    const SizedBox(width: 8),
                                    Text(CurrencyUtils.format(e.value, cur),
                                      style: const TextStyle(fontFamily: 'Outfit', fontSize: 13,
                                        color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: pct.toDouble(),
                                    backgroundColor: AppColors.bg3,
                                    valueColor: AlwaysStoppedAnimation(color),
                                    minHeight: 5,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                    ],
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

  Widget _buildPieChart(Map<String, double> expByCat, CategoryProvider cats) {
    final entries = expByCat.entries.toList();
    return PieChart(
      PieChartData(
        sections: List.generate(entries.length, (i) {
          final isTouched = i == _touchedIndex;
          final cat = cats.findById(entries[i].key);
          final color = cat?.color ?? AppColors.categoryPalette[i % AppColors.categoryPalette.length];
          final total = expByCat.values.fold(0.0, (s, v) => s + v);
          final pct = entries[i].value / total * 100;
          return PieChartSectionData(
            color: color,
            value: entries[i].value,
            title: isTouched ? '${pct.toStringAsFixed(1)}%' : '',
            radius: isTouched ? 90 : 75,
            titleStyle: const TextStyle(
              fontFamily: 'Outfit', fontWeight: FontWeight.w700,
              fontSize: 12, color: Colors.white,
            ),
            badgeWidget: isTouched ? null : null,
          );
        }),
        sectionsSpace: 2,
        centerSpaceRadius: 30,
        pieTouchData: PieTouchData(
          touchCallback: (_, response) {
            setState(() {
              _touchedIndex = response?.touchedSection?.touchedSectionIndex ?? -1;
            });
          },
        ),
      ),
      swapAnimationDuration: const Duration(milliseconds: 800),
      swapAnimationCurve: Curves.easeOutBack,
    );
  }

  Widget _buildLegend(Map<String, double> expByCat, CategoryProvider cats, String cur) {
    final entries = expByCat.entries.toList();
    return ListView.builder(
      itemCount: entries.length,
      itemBuilder: (_, i) {
        final cat = cats.findById(entries[i].key);
        final color = cat?.color ?? AppColors.categoryPalette[i % AppColors.categoryPalette.length];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Container(width: 10, height: 10,
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
              const SizedBox(width: 6),
              Expanded(
                child: Text(cat?.name ?? entries[i].key,
                  style: const TextStyle(fontFamily: 'Outfit', fontSize: 11, color: AppColors.textSecondary),
                  overflow: TextOverflow.ellipsis, maxLines: 1),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBarChart(List<double> weekly, String cur) {
    final days = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    final now  = DateTime.now();
    final maxY = weekly.isEmpty ? 10.0 : (weekly.reduce((a,b) => a>b?a:b) * 1.3).clamp(1.0, double.infinity);

    return BarChart(
      BarChartData(
        maxY: maxY,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (_, __, rod, ___) => BarTooltipItem(
              CurrencyUtils.format(rod.toY, cur),
              const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w600, color: Colors.white, fontSize: 12),
            ),
          ),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, _) {
                final dayOffset = now.weekday - 1;
                final idx = v.toInt();
                final dayIdx = (dayOffset - 6 + idx + 7) % 7;
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(days[dayIdx],
                    style: const TextStyle(fontFamily: 'Outfit', fontSize: 10, color: AppColors.textMuted)),
                );
              },
              reservedSize: 24,
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => const FlLine(color: AppColors.bg3, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(7, (i) {
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: weekly.isEmpty ? 0 : weekly[i],
                width: 22,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    AppColors.accent.withValues(alpha: 0.6),
                    AppColors.accentLight,
                  ],
                ),
              ),
            ],
          );
        }),
      ),
      swapAnimationDuration: const Duration(milliseconds: 800),
      swapAnimationCurve: Curves.easeOutQuart,
    );
  }
}

class _NoPieData extends StatelessWidget {
  const _NoPieData();
  @override
  Widget build(BuildContext context) => const Center(
    child: Padding(
      padding: EdgeInsets.all(20),
      child: Text('No expense data this month',
        style: TextStyle(fontFamily: 'Outfit', color: AppColors.textMuted)),
    ),
  );
}

