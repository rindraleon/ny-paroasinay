import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/transaction.dart';
import '../widgets/money.dart';

class PdfReportService {
  static Future<void> shareGlobalReport(
    List<CashTransaction> transactions,
  ) async {
    final int income = transactions
        .where((CashTransaction tx) => tx.type == TransactionType.income)
        .fold(0, (int sum, CashTransaction tx) => sum + tx.amount);
    final int expense = transactions
        .where((CashTransaction tx) => tx.type == TransactionType.expense)
        .fold(0, (int sum, CashTransaction tx) => sum + tx.amount);
    final pw.Document document = pw.Document();
    final DateFormat dateFormat = DateFormat('dd/MM/yyyy');

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (pw.Context context) => <pw.Widget>[
          pw.Text(
            'NY PAROASINAY',
            style: const pw.TextStyle(
              fontSize: 22,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Text('Paroisse Saint Francois d’Assise — Tsararivotra Ambalavao'),
          pw.SizedBox(height: 6),
          pw.Text(
            'Rapport de tresorerie genere le ${dateFormat.format(DateTime.now())}',
          ),
          pw.Divider(),
          pw.Row(
            children: <pw.Widget>[
              _amountBox('Total des entrees', income, PdfColors.green),
              pw.SizedBox(width: 12),
              _amountBox('Total des sorties', expense, PdfColors.red),
              pw.SizedBox(width: 12),
              _amountBox('Solde', income - expense, PdfColors.blue),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Text(
            'Liste des operations',
            style: const pw.TextStyle(
              fontSize: 15,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.TableHelper.fromTextArray(
            headerStyle: const pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.green700),
            cellAlignment: pw.Alignment.centerLeft,
            headers: <String>[
              'Date',
              'Type',
              'Categorie',
              'Libelle',
              'Montant',
            ],
            data: transactions
                .map(
                  (CashTransaction tx) => <String>[
                    dateFormat.format(tx.date),
                    tx.type == TransactionType.income ? 'Entree' : 'Sortie',
                    tx.category,
                    tx.description,
                    '${tx.type == TransactionType.income ? '+' : '-'}${money(tx.amount)}',
                  ],
                )
                .toList(),
          ),
          pw.SizedBox(height: 14),
          pw.Text(
            'Document confidentiel — Tresorerie de la paroisse.',
            style: const pw.TextStyle(fontSize: 9),
          ),
        ],
      ),
    );
    final Uint8List bytes = await document.save();
    await Printing.sharePdf(
      bytes: bytes,
      filename:
          'rapport_ny_paroasinay_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
    );
  }

  static pw.Widget _amountBox(String label, int value, PdfColor color) =>
      pw.Expanded(
        child: pw.Container(
          padding: const pw.EdgeInsets.all(8),
          decoration: pw.BoxDecoration(border: pw.Border.all(color: color)),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: <pw.Widget>[
              pw.Text(label, style: const pw.TextStyle(fontSize: 9)),
              pw.SizedBox(height: 4),
              pw.Text(
                money(value),
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      );
}
