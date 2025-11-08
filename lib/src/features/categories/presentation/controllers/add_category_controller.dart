// lib/src/features/categories/presentation/controllers/add_category_controller.dart

import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:budgit/src/constants/app_icons.dart';
import 'package:budgit/src/features/categories/domain/category.dart';
import 'package:budgit/src/features/transactions/data/transaction_repository_provider.dart';
import 'package:budgit/src/features/categories/presentation/providers/category_list_provider.dart';

part 'add_category_controller.g.dart';

@immutable
class AddCategoryState {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final bool isLoading;

  const AddCategoryState({
    required this.id,
    this.name = '',
    this.icon = AppIcons.defaultIcon,
    this.color = Colors.blue,
    this.isLoading = false,
  });

  AddCategoryState copyWith({
    String? id,
    String? name,
    IconData? icon,
    Color? color,
    bool? isLoading,
  }) {
    return AddCategoryState(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

@riverpod
class AddCategoryController extends _$AddCategoryController {
  
  @override
  AddCategoryState build() {
    // We can now use autoDispose as the state doesn't need to be preserved
    // across a complex wizard flow.
    ref.onDispose(() {
      // Logic to run when the provider is disposed.
    });
    return AddCategoryState(id: const Uuid().v4());
  }

  // --- REPLACED saveAndFinish with a simpler method ---
  Future<Category?> saveCategory() async {
    if (state.name.trim().isEmpty) {
      // Don't save if the name is empty
      return null;
    }
    state = state.copyWith(isLoading: true);
    try {
      final repository = ref.read(transactionRepositoryProvider);
      
      // Create a new category with 0 for budget fields
      final newCategory = Category(
        id: state.id,
        name: state.name,
        iconCodePoint: state.icon.codePoint,
        iconFontFamily: state.icon.fontFamily,
        iconFontPackage: state.icon.fontPackage,
        colorValue: state.color.value,
        budgetAmount: 0.0, // Default to 0
        walletAmount: 0.0, // Default to 0
      );

      await repository.addCategory(newCategory);
      ref.invalidate(categoryListProvider);
      return newCategory;
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
}