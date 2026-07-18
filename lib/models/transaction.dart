enum TransactionType { income, expense }

extension TransactionTypeLabel on TransactionType {
  String get label => this == TransactionType.income ? 'Entrée' : 'Sortie';
  String get databaseValue =>
      this == TransactionType.income ? 'income' : 'expense';
  static TransactionType fromDatabase(String value) =>
      value == 'income' ? TransactionType.income : TransactionType.expense;
}

class CashTransaction {
  const CashTransaction({
    this.id,
    required this.type,
    required this.amount,
    required this.date,
    required this.category,
    required this.description,
    this.party,
    this.reference,
    this.paymentMethod = 'Espèces',
    this.isAnonymous = false,
  });

  final int? id;
  final TransactionType type;
  final int amount;
  final DateTime date;
  final String category;
  final String description;
  final String? party;
  final String? reference;
  final String paymentMethod;
  final bool isAnonymous;

  Map<String, Object?> toMap() => <String, Object?>{
        'id': id,
        'type': type.databaseValue,
        'amount': amount,
        'date': date.toIso8601String(),
        'category': category,
        'description': description,
        'party': party,
        'reference': reference,
        'payment_method': paymentMethod,
        'is_anonymous': isAnonymous ? 1 : 0,
      };

  factory CashTransaction.fromMap(Map<String, Object?> map) => CashTransaction(
        id: map['id'] as int?,
        type: TransactionTypeLabel.fromDatabase(map['type'] as String),
        amount: map['amount'] as int,
        date: DateTime.parse(map['date'] as String),
        category: map['category'] as String,
        description: map['description'] as String,
        party: map['party'] as String?,
        reference: map['reference'] as String?,
        paymentMethod: map['payment_method'] as String? ?? 'Espèces',
        isAnonymous: (map['is_anonymous'] as int? ?? 0) == 1,
      );
}
