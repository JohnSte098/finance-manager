// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'data/datasources/hive_db.dart';
import 'presentation/pages/categories_page.dart';
import 'presentation/pages/home_shell.dart';
import 'presentation/pages/auth_page.dart';
import 'presentation/pages/settings_page.dart';
import 'presentation/providers/budget_provider.dart';
import 'presentation/providers/category_provider.dart';
import 'presentation/providers/settings_provider.dart';
import 'presentation/providers/transaction_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Force portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Status bar style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppColors.bg1,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  // Init Hive
  await HiveDb.init();

  runApp(const MoneyManagerApp());
}

class MoneyManagerApp extends StatefulWidget {
  const MoneyManagerApp({super.key});

  @override
  State<MoneyManagerApp> createState() => _MoneyManagerAppState();
}

class _MoneyManagerAppState extends State<MoneyManagerApp> {
  late final CategoryProvider    _catProvider;
  late final TransactionProvider _txProvider;
  late final BudgetProvider      _budgetProvider;
  late final SettingsProvider    _settingsProvider;

  @override
  void initState() {
    super.initState();
    _catProvider      = CategoryProvider();
    _txProvider       = TransactionProvider();
    _budgetProvider   = BudgetProvider();
    _settingsProvider = SettingsProvider();

    // Seed default categories on first launch
    _catProvider.seedDefaults();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _catProvider),
        ChangeNotifierProvider.value(value: _txProvider),
        ChangeNotifierProvider.value(value: _budgetProvider),
        ChangeNotifierProvider.value(value: _settingsProvider),
      ],
      child: MaterialApp(
        title: 'Money Tracker',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        themeMode: ThemeMode.dark,
        initialRoute: '/',
        routes: {
          '/': (context) {
            final isLocked = context.watch<SettingsProvider>().biometricEnabled;
            return isLocked ? const AuthPage() : const HomeShell();
          },
          '/categories': (_) => const CategoriesPage(),
          '/settings': (_) => const SettingsPage(),
        },
      ),
    );
  }
}
