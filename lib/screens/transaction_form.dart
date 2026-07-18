import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/transaction.dart';
import '../providers/transactions_provider.dart';

const List<String> incomeCategories = <String>[
  'Quête / offrande',
  'Don',
  'Dîme',
  'Contribution des fidèles',
  'Vente / activité paroissiale',
  'Location',
  'Subvention',
  'Autre revenu',
];

const List<String> expenseCategories = <String>[
  'Électricité / eau',
  'Entretien et réparation',
  'Achat de fournitures',
  'Liturgie et activités pastorales',
  'Prêtres',
  'Aide sociale / charité',
  'Transport',
  'Communication',
  'Construction / aménagement',
  'Autre dépense',
];

class TransactionForm extends ConsumerStatefulWidget {
  const TransactionForm({super.key, this.transaction});
  final CashTransaction? transaction;

  @override
  ConsumerState<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends ConsumerState<TransactionForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _amount;
  late final TextEditingController _description;
  late final TextEditingController _party;
  late final TextEditingController _reference;
  late TransactionType _type;
  late DateTime _date;
  late String _category;
  late String _paymentMethod;
  late bool _anonymous;

  @override
  void initState() {
    super.initState();
    final CashTransaction? tx = widget.transaction;
    _type = tx?.type ?? TransactionType.income;
    _date = tx?.date ?? DateTime.now();
    _category = tx?.category ?? incomeCategories.first;
    _paymentMethod = tx?.paymentMethod ?? 'Espèces';
    _anonymous = tx?.isAnonymous ?? false;
    _amount = TextEditingController(text: tx?.amount.toString() ?? '');
    _description = TextEditingController(text: tx?.description ?? '');
    _party = TextEditingController(text: tx?.party ?? '');
    _reference = TextEditingController(text: tx?.reference ?? '');
  }

  @override
  void dispose() {
    _amount.dispose();
    _description.dispose();
    _party.dispose();
    _reference.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<String> categories =
        _type == TransactionType.income ? incomeCategories : expenseCategories;
    if (!categories.contains(_category)) {
      _category = categories.first;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.transaction == null
              ? 'Nouvelle opération'
              : 'Modifier l\'opération',
        ),
        actions: <Widget>[
          if (widget.transaction != null)
            IconButton(
              onPressed: _delete,
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Supprimer',
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            SegmentedButton<TransactionType>(
              segments: const <ButtonSegment<TransactionType>>[
                ButtonSegment(
                  value: TransactionType.income,
                  label: Text('Entrée'),
                  icon: Icon(Icons.add_circle_outline),
                ),
                ButtonSegment(
                  value: TransactionType.expense,
                  label: Text('Sortie'),
                  icon: Icon(Icons.remove_circle_outline),
                ),
              ],
              selected: <TransactionType>{_type},
              onSelectionChanged: (Set<TransactionType> selected) {
                setState(() {
                  _type = selected.first;
                  _category = (_type == TransactionType.income
                          ? incomeCategories
                          : expenseCategories)
                      .first;
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amount,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Montant (Ar) *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.payments_outlined),
              ),
              validator: (String? value) {
                if (int.tryParse(value ?? '') == null ||
                    int.parse(value!) <= 0) {
                  return 'Saisissez un montant valide';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(
                labelText: 'Catégorie *',
                border: OutlineInputBorder(),
              ),
              items: categories
                  .map((String x) => DropdownMenuItem(
                        value: x,
                        child: Text(x),
                      ))
                  .toList(),
              onChanged: (String? x) => setState(() => _category = x!),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _description,
              decoration: const InputDecoration(
                labelText: 'Libellé / motif *',
                border: OutlineInputBorder(),
              ),
              validator: (String? value) {
                if ((value ?? '').trim().isEmpty) {
                  return 'Ce champ est obligatoire';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
                side: BorderSide(color: Theme.of(context).colorScheme.outline),
              ),
              title: const Text('Date'),
              subtitle: Text(
                DateFormat('EEEE d MMMM y', 'fr').format(_date),
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickDate,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _party,
              decoration: InputDecoration(
                labelText: _type == TransactionType.income
                    ? 'Donateur / origine (facultatif)'
                    : 'Bénéficiaire / fournisseur (facultatif)',
                border: const OutlineInputBorder(),
              ),
            ),
            if (_type == TransactionType.income && _category == 'Don')
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Don anonyme'),
                value: _anonymous,
                onChanged: (bool value) => setState(() => _anonymous = value),
              ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _reference,
              decoration: const InputDecoration(
                labelText: 'Référence / reçu (facultatif)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: _paymentMethod,
              decoration: const InputDecoration(
                labelText: 'Mode de paiement',
                border: OutlineInputBorder(),
              ),
              items: const <String>[
                'Espèces',
                'Mobile Money',
                'Virement',
                'Autre',
              ]
                  .map(
                    (String x) => DropdownMenuItem(
                      value: x,
                      child: Text(x),
                    ),
                  )
                  .toList(),
              onChanged: (String? x) => setState(() => _paymentMethod = x!),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Enregistrer'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final DateTime? chosen = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale('fr'),
    );
    if (chosen != null) {
      setState(() => _date = chosen);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    await ref.read(transactionsProvider.notifier).save(
          CashTransaction(
            id: widget.transaction?.id,
            type: _type,
            amount: int.parse(_amount.text),
            date: _date,
            category: _category,
            description: _description.text.trim(),
            party: _anonymous ? null : _party.text.trim(),
            reference: _reference.text.trim(),
            paymentMethod: _paymentMethod,
            isAnonymous: _anonymous,
          ),
        );

    if (mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _delete() async {
    final bool? yes = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Supprimer cette opération ?'),
          content: const Text('Cette action est définitive.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );

    if (yes == true) {
      await ref
          .read(transactionsProvider.notifier)
          .delete(widget.transaction!.id!);
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }
}
