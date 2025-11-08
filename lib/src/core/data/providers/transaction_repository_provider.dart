import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:budgit/src/core/data/repositories/hive_transaction_repository.dart';
import 'package:budgit/src/core/data/repositories/transaction_repository.dart';

part 'transaction_repository_provider.g.dart';

@Riverpod(keepAlive: true)
TransactionRepository transactionRepository(Ref ref) {
  // Pass the ref to the repository so it can read other providers
  return HiveTransactionRepository(ref);
}
