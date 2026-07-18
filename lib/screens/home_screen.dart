import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/transaction.dart';
import '../providers/transactions_provider.dart';
import '../widgets/money.dart';
import 'transaction_form.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<CashTransaction>> transactions =
        ref.watch(transactionsProvider);
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E7),
      appBar: AppBar(
        title: const Text('Paroisse St François d\'Assise'),
        actions: <Widget>[
          IconButton(
            onPressed: () => ref.invalidate(transactionsProvider),
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: transactions.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace stack) =>
            Center(child: Text('Erreur : $error')),
        data: (List<CashTransaction> items) => _page(items),
      ),
      floatingActionButton: _index == 0
          ? FloatingActionButton.extended(
              onPressed: _add,
              icon: const Icon(Icons.add),
              label: const Text('Opération'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (int value) => setState(() => _index = value),
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Accueil',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Journal',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Rapport',
          ),
        ],
      ),
    );
  }

  Widget _page(List<CashTransaction> items) {
    switch (_index) {
      case 1:
        return _journal(items);
      case 2:
        return _report(items);
      default:
        return _dashboard(items);
    }
  }

  Widget _dashboard(List<CashTransaction> items) {
    final DateTime now = DateTime.now();
    final Iterable<CashTransaction> monthly = items.where(
      (CashTransaction x) =>
          x.date.year == now.year && x.date.month == now.month,
    );
    final int income = monthly
        .where((CashTransaction x) => x.type == TransactionType.income)
        .fold(0, (int a, CashTransaction x) => a + x.amount);
    final int expense = monthly
        .where((CashTransaction x) => x.type == TransactionType.expense)
        .fold(0, (int a, CashTransaction x) => a + x.amount);
    final int balance = ref.read(balanceProvider);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Row(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset(
                'assets/icons/saint_francois_app_icon.png',
                width: 54,
                height: 54,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Paroisse St François d\'Assise',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text('Saint François d’Assise',
                      style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Card(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Row(
                  children: <Widget>[
                    Icon(Icons.account_balance_wallet_outlined),
                    SizedBox(width: 8),
                    Text('SOLDE ACTUEL'),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  money(balance),
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            Expanded(child: _stat('Entrées ce mois', income, Colors.green)),
            const SizedBox(width: 12),
            Expanded(child: _stat('Sorties ce mois', expense, Colors.red)),
          ],
        ),
        const SizedBox(height: 22),
        Text('Opérations récentes',
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        if (items.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(18),
              child: Text(
                  'Aucune opération. Appuyez sur « Opération » pour commencer.'),
            ),
          )
        else
          ...items.take(5).map(_transactionTile),
      ],
    );
  }

  Widget _stat(String label, int value, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(
              label.startsWith('Entrées')
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              color: color,
            ),
            const SizedBox(height: 6),
            Text(label),
            const SizedBox(height: 8),
            Text(
              money(value),
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _journal(List<CashTransaction> items) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Text('Journal de caisse',
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        if (items.isEmpty)
          const Text('Aucune opération enregistrée.')
        else
          ...items.map(_transactionTile),
      ],
    );
  }

  Widget _report(List<CashTransaction> items) {
    final int income = items
        .where((CashTransaction x) => x.type == TransactionType.income)
        .fold(0, (int a, CashTransaction x) => a + x.amount);
    final int expense = items
        .where((CashTransaction x) => x.type == TransactionType.expense)
        .fold(0, (int a, CashTransaction x) => a + x.amount);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Text('Rapport global', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: <Widget>[
              ListTile(
                title: const Text('Total des entrées'),
                leading: const Icon(Icons.arrow_downward, color: Colors.green),
                trailing: Text(
                  money(income),
                  style: const TextStyle(
                      color: Colors.green, fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                title: const Text('Total des sorties'),
                leading: const Icon(Icons.arrow_upward, color: Colors.red),
                trailing: Text(
                  money(expense),
                  style: const TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                title: const Text('Solde'),
                leading: const Icon(Icons.account_balance_wallet_outlined),
                trailing: Text(
                  money(income - expense),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _transactionTile(CashTransaction transaction) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: transaction.type == TransactionType.income
              ? Colors.green.shade100
              : Colors.red.shade100,
          child: Icon(
            transaction.type == TransactionType.income
                ? Icons.south_west
                : Icons.north_east,
            color: transaction.type == TransactionType.income
                ? Colors.green
                : Colors.red,
          ),
        ),
        title: Text(transaction.description),
        subtitle: Text(
            '${transaction.category} • ${DateFormat('dd/MM/yyyy').format(transaction.date)}'),
        trailing: Text(
          '${transaction.type == TransactionType.income ? '+' : '−'}${money(transaction.amount)}',
          style: TextStyle(
            color: transaction.type == TransactionType.income
                ? Colors.green
                : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: () => _add(transaction),
      ),
    );
  }

  Future<void> _add([CashTransaction? transaction]) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TransactionForm(transaction: transaction),
      ),
    );
  }
}
