import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:budgit/src/app.dart';
import 'package:budgit/src/features/savings/domain/savings_goal.dart';
import 'package:budgit/src/features/categories/domain/category.dart';
import 'package:budgit/src/features/transactions/domain/transaction.dart';
import 'package:budgit/src/features/wallet/domain/wallet_adjustment.dart';
import 'package:budgit/src/features/settings/domain/screen_layout.dart';

Future<void> main() async {
  // 1. Ensure Flutter is ready
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialize Hive
  await Hive.initFlutter();

  // 3. Register all your adapters
  Hive.registerAdapter(CategoryAdapter());
  Hive.registerAdapter(BudgetPeriodAdapter());
  Hive.registerAdapter(RecurrencePeriodAdapter());
  Hive.registerAdapter(OneOffPaymentAdapter());
  Hive.registerAdapter(RecurringPaymentAdapter());
  Hive.registerAdapter(OneOffIncomeAdapter());
  Hive.registerAdapter(RecurringIncomeAdapter());
  Hive.registerAdapter(PaymentOccurrenceAdapter());
  Hive.registerAdapter(IncomeOccurrenceAdapter());
  Hive.registerAdapter(WalletAdjustmentAdapter());
  Hive.registerAdapter(SavingsGoalAdapter());
  Hive.registerAdapter(ScreenLayoutAdapter());

  // 4. Open all your boxes (ensure every line has 'await')
  await Hive.openBox<Category>('categories');
  await Hive.openBox<Transaction>('transactions');
  await Hive.openBox<WalletAdjustment>('adjustments');
  await Hive.openBox<SavingsGoal>('savings_goals');
  await Hive.openBox('settings');
  await Hive.openBox<ScreenLayout>('layouts');

  // 5. Run the app
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
