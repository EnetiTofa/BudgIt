// main.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:budgit/src/app.dart';
import 'package:budgit/src/core/domain/models/savings_goal.dart';
import 'package:budgit/src/core/domain/models/category.dart';
import 'package:budgit/src/core/domain/enums/budget_enum.dart';
import 'package:budgit/src/core/domain/models/transaction.dart';
import 'package:budgit/src/features/budget_hub/wallet/domain/wallet_adjustment.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

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

  await Hive.openBox<Category>('categories');
  await Hive.openBox<Transaction>('transactions');
  await Hive.openBox<WalletAdjustment>('adjustments');
  await Hive.openBox<SavingsGoal>('savings_goals');
  await Hive.openBox('settings');
  
  // This was the missing line that caused the error
  await Hive.openBox<List<String>>('category_order');

  // Run the app
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}