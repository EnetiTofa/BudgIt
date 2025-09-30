// lib/src/features/categories/presentation/controllers/add_category_controller.dart

import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:budgit/src/constants/app_icons.dart';
import 'package:budgit/src/features/categories/domain/category.dart';
import 'package:budgit/src/features/categories/domain/budget_enum.dart';
import 'package:budgit/src/features/categories/presentation/providers/add_category_providers.dart';
import 'package:budgit/src/features/transactions/data/transaction_repository_provider.dart';
import 'package:budgit/src/features/categories/presentation/providers/category_list_provider.dart';


part 'add_category_controller.g.dart';

enum AddCategoryStep {
  basics,
  recurring,
  wallet,
  budget,
  summary,
}

@immutable
class AddCategoryState {
  final PageController pageController;
  final AddCategoryStep step;
  final String? id;
  final String name;
  final IconData icon;
  final Color color;
  final BudgetPeriod budgetPeriod;
  final double? walletAmount;
  final double? budgetAmount;
  final bool isLoading; // Added for loading indicator

  const AddCategoryState({
    required this.pageController,
    this.step = AddCategoryStep.basics,
    this.id,
    this.name = '',
    this.icon = AppIcons.defaultIcon,
    this.color = Colors.blue,
    this.budgetPeriod = BudgetPeriod.monthly,
    this.walletAmount,
    this.budgetAmount,
    this.isLoading = false, // Default to not loading
  });
  
  Category toCategory() {
    double monthlyBudget;
    switch (budgetPeriod) {
      case BudgetPeriod.weekly:
        monthlyBudget = (budgetAmount ?? 0.0) * 4.33;
        break;
      case BudgetPeriod.monthly:
        monthlyBudget = budgetAmount ?? 0.0;
        break;
      case BudgetPeriod.yearly:
        monthlyBudget = (budgetAmount ?? 0.0) / 12;
        break;
    }

    return Category(
      id: id!,
      name: name,
      iconCodePoint: icon.codePoint,
      iconFontFamily: icon.fontFamily,
      colorValue: color.value,
      budgetAmount: monthlyBudget,
      walletAmount: walletAmount,
    );
  }

  AddCategoryState copyWith({
    PageController? pageController,
    AddCategoryStep? step,
    String? id,
    String? name,
    IconData? icon,
    Color? color,
    BudgetPeriod? budgetPeriod,
    double? walletAmount,
    double? budgetAmount,
    bool? isLoading, // Added for loading indicator
  }) {
    return AddCategoryState(
      pageController: pageController ?? this.pageController,
      step: step ?? this.step,
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      budgetPeriod: budgetPeriod ?? this.budgetPeriod,
      walletAmount: walletAmount ?? this.walletAmount,
      budgetAmount: budgetAmount ?? this.budgetAmount,
      isLoading: isLoading ?? this.isLoading, // Added for loading indicator
    );
  }
}

@riverpod
class AddCategoryController extends _$AddCategoryController {
  
  @override
  AddCategoryState build() {
    final pageController = PageController();

    ref.onDispose(() {
      pageController.dispose();
    });

    return AddCategoryState(
      id: const Uuid().v4(),
      pageController: pageController,
    );
  }

  // --- NEW METHOD TO SAVE EVERYTHING ---
  Future<void> saveAndFinish() async {
    state = state.copyWith(isLoading: true);
    try {
      final repository = ref.read(transactionRepositoryProvider);
      final recurringPayments = ref.read(tempRecurringPaymentsProvider);
      final newCategory = state.toCategory();

      await repository.addCategory(newCategory);

      for (final payment in recurringPayments) {
        await repository.addTransaction(payment);
      }
      ref.invalidate(categoryListProvider);

    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
  
  void setName(String name) {
    state = state.copyWith(name: name);
  }

  void setIcon(IconData icon) {
    state = state.copyWith(icon: icon);
  }

  void setColor(Color color) {
    state = state.copyWith(color: color);
  }
  
  void setWallet(double amount) {
    state = state.copyWith(walletAmount: amount);
  }

  void setFinalBudget({required double amount, required BudgetPeriod period}) {
    state = state.copyWith(budgetAmount: amount, budgetPeriod: period);
  }
  
  void nextStep() {
    if (state.step.index < AddCategoryStep.values.length - 1) {
      state.pageController.jumpToPage(state.step.index + 1);
    }
  }
  
  void previousStep() {
     if (state.step.index > 0) {
      state.pageController.jumpToPage(state.step.index - 1);
    }
  }

  void onPageChanged(int pageIndex) {
    state = state.copyWith(step: AddCategoryStep.values[pageIndex]);
  }
}