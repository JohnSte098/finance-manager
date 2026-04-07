// lib/presentation/pages/add_transaction_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/default_categories.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/smart_categorizer.dart';
import '../../data/models/category_model.dart';
import '../providers/category_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/transaction_provider.dart';

class AddTransactionSheet extends StatefulWidget {
  const AddTransactionSheet({super.key});

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey   = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _amtCtrl   = TextEditingController();
  final _noteCtrl  = TextEditingController();

  bool   _isExpense   = true;
  String? _selectedCatId;
  DateTime _date       = DateTime.now();
  bool    _recurring   = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() => _isExpense = _tabController.index == 0);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleCtrl.dispose();
    _amtCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  void _onTitleChanged(String val) {
    final suggested = SmartCategorizer.suggest(val);
    if (suggested != null && _selectedCatId == null) {
      setState(() => _selectedCatId = suggested);
    }
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(primary: AppColors.accent),
        ),
        child: child!,
      ),
    );
    if (d != null) setState(() => _date = d);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCatId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category'), backgroundColor: AppColors.warning),
      );
      return;
    }

    final settings = context.read<SettingsProvider>();
    await context.read<TransactionProvider>().addTransaction(
      title: _titleCtrl.text.trim(),
      amount: double.parse(_amtCtrl.text.trim()),
      categoryId: _selectedCatId!,
      date: _date,
      isExpense: _isExpense,
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      currency: settings.currency,
      isRecurring: _recurring,
    );

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final cats = context.watch<CategoryProvider>();
    final displayCats = _isExpense ? cats.expenseCategories : cats.incomeCategories;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bg1,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          const SizedBox(height: 10),
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppColors.bg3,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Text('Add Transaction',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                ),
              ],
            ),
          ),

          // Type Tab
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.bg3,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: _isExpense ? AppColors.expense.withValues(alpha: 0.2) : AppColors.income.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: _isExpense ? AppColors.expense : AppColors.income,
                unselectedLabelColor: AppColors.textMuted,
                labelStyle: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w600, fontSize: 14),
                tabs: const [
                  Tab(text: '  Expense  '),
                  Tab(text: '  Income  '),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Form
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 20, right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Amount input
                    _buildAmountInput(),
                    const SizedBox(height: 14),

                    // Title
                    TextFormField(
                      controller: _titleCtrl,
                      onChanged: _onTitleChanged,
                      style: const TextStyle(color: AppColors.textPrimary, fontFamily: 'Outfit'),
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        prefixIcon: Icon(Icons.edit_note_rounded, color: AppColors.textMuted, size: 20),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a title' : null,
                    ),
                    const SizedBox(height: 14),

                    // Category picker
                    _buildCategoryPicker(displayCats),
                    const SizedBox(height: 14),

                    // Date & Note row
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: _pickDate,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
                              decoration: BoxDecoration(
                                color: AppColors.bg3,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppColors.bg3, width: 1),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_month_rounded,
                                    color: AppColors.textMuted, size: 18),
                                  const SizedBox(width: 8),
                                  Text(_formatDate(_date),
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontFamily: 'Outfit',
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _recurring = !_recurring),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
                              decoration: BoxDecoration(
                                color: _recurring
                                    ? AppColors.accent.withValues(alpha: 0.15)
                                    : AppColors.bg3,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: _recurring ? AppColors.accent : AppColors.bg3,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.repeat_rounded,
                                    color: _recurring ? AppColors.accentLight : AppColors.textMuted,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text('Recurring',
                                    style: TextStyle(
                                      color: _recurring ? AppColors.accentLight : AppColors.textPrimary,
                                      fontFamily: 'Outfit',
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Note
                    TextFormField(
                      controller: _noteCtrl,
                      style: const TextStyle(color: AppColors.textPrimary, fontFamily: 'Outfit'),
                      decoration: const InputDecoration(
                        labelText: 'Note (optional)',
                        prefixIcon: Icon(Icons.notes_rounded, color: AppColors.textMuted, size: 20),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 24),

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isExpense ? AppColors.expense : AppColors.income,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        onPressed: _submit,
                        child: Text(
                          _isExpense ? 'Add Expense' : 'Add Income',
                          style: const TextStyle(
                            fontFamily: 'Outfit',
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _isExpense
            ? [AppColors.expense.withValues(alpha: 0.12), AppColors.expense.withValues(alpha: 0.05)]
            : [AppColors.income.withValues(alpha: 0.12), AppColors.income.withValues(alpha: 0.05)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: (_isExpense ? AppColors.expense : AppColors.income).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Text(
            context.watch<SettingsProvider>().currency == 'INR' ? '₹' :
            context.watch<SettingsProvider>().currency == 'EUR' ? '€' : '\$',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: (_isExpense ? AppColors.expense : AppColors.income).withValues(alpha: 0.7),
              fontFamily: 'Outfit',
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              controller: _amtCtrl,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: _isExpense ? AppColors.expense : AppColors.income,
                fontFamily: 'Outfit',
                letterSpacing: -1,
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
              decoration: InputDecoration(
                hintText: '0.00',
                hintStyle: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: (_isExpense ? AppColors.expense : AppColors.income).withValues(alpha: 0.3),
                  fontFamily: 'Outfit',
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                contentPadding: EdgeInsets.zero,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Enter amount';
                final n = double.tryParse(v.trim());
                if (n == null || n <= 0) return 'Invalid amount';
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryPicker(List<CategoryModel> cats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Category',
              style: TextStyle(color: AppColors.textSecondary, fontFamily: 'Outfit', fontSize: 13),
            ),
            const Spacer(),
            GestureDetector(
              onTap: _openManageCategories,
              child: const Row(
                children: [
                  Icon(Icons.settings_rounded, size: 13, color: AppColors.accentLight),
                  SizedBox(width: 4),
                  Text('Manage', style: TextStyle(fontSize: 12, color: AppColors.accentLight, fontFamily: 'Outfit')),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...cats.map((cat) {
              final selected = _selectedCatId == cat.id;
              return GestureDetector(
                onTap: () => setState(() => _selectedCatId = cat.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected ? cat.color.withValues(alpha: 0.2) : AppColors.bg3,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selected ? cat.color : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(CategoryIcons.iconFor(cat.iconName), color: cat.color, size: 14),
                      const SizedBox(width: 6),
                      Text(cat.name,
                        style: TextStyle(
                          color: selected ? cat.color : AppColors.textSecondary,
                          fontFamily: 'Outfit',
                          fontSize: 12,
                          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            // Add custom
            GestureDetector(
              onTap: _openManageCategories,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.bg3,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.accent.withValues(alpha: 0.4), width: 1.5),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_rounded, color: AppColors.accentLight, size: 14),
                    SizedBox(width: 4),
                    Text('Custom', style: TextStyle(color: AppColors.accentLight, fontFamily: 'Outfit', fontSize: 12)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _openManageCategories() {
    Navigator.pop(context);
    // Navigate to category management page
    Navigator.pushNamed(context, '/categories');
  }

  String _formatDate(DateTime d) {
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}

