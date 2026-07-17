import 'package:flutter_test/flutter_test.dart';
import 'package:paroisse_tresorerie/models/transaction.dart';

void main() {
  test('transaction conversion preserves fields', () {
    final CashTransaction source = CashTransaction(
      type: TransactionType.expense,
      amount: 25000,
      date: DateTime(2026, 7, 17),
      category: 'Prêtres',
      description: 'Allocation mensuelle',
    );
    final CashTransaction restored = CashTransaction.fromMap(
      source.toMap()..['id'] = 1,
    );
    expect(restored.category, 'Prêtres');
    expect(restored.amount, 25000);
    expect(restored.type, TransactionType.expense);
  });
}
