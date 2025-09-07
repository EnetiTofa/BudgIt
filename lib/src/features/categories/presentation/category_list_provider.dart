import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:budgit/src/features/transactions/data/transaction_repository_provider.dart';
import 'package:budgit/src/features/categories/domain/category.dart';

part 'category_list_provider.g.dart';

@riverpod
Future<List<Category>> categoryList(Ref ref) async {
  final repository = ref.watch(transactionRepositoryProvider);
  return repository.getAllCategories();
}