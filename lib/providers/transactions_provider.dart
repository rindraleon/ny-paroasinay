import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/database_service.dart';
import '../models/transaction.dart';

final transactionsProvider =
    AsyncNotifierProvider<TransactionsNotifier, List<CashTransaction>>(
      TransactionsNotifier.new,
    );

class TransactionsNotifier extends AsyncNotifier<List<CashTransaction>> {
  @override
  Future<List<CashTransaction>> build() =>
      DatabaseService.instance.allTransactions();

  Future<void> save(CashTransaction transaction) async {
    await DatabaseService.instance.save(transaction);
    state = AsyncData(await DatabaseService.instance.allTransactions());
  }

  Future<void> delete(int id) async {
    await DatabaseService.instance.delete(id);
    state = AsyncData(await DatabaseService.instance.allTransactions());
  }
}

final balanceProvider = Provider<int>(
  (Ref ref) =>
      ref
          .watch(transactionsProvider)
          .valueOrNull
          ?.fold<int>(
            0,
            (int value, CashTransaction tx) =>
                value +
                (tx.type == TransactionType.income ? tx.amount : -tx.amount),
          ) ??
      0,
);
