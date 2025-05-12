import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import '../db/transaction_database.dart';
import '../models/transaction.dart';

class SettingsScreen extends StatelessWidget {
  Future<void> _exportToCSV(BuildContext context) async {
    final status = await Permission.storage.request();

    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Permission refusée")),
      );
      return;
    }

    final transactions = await TransactionDatabase.instance.getAllTransactions();

    final List<List<dynamic>> rows = [
      ["ID", "Titre", "Montant", "Date", "Catégorie", "Type"],
      ...transactions.map((t) => t.toCSV()),
    ];

    final csvData = const ListToCsvConverter().convert(rows);
    final directory = await getExternalStorageDirectory();
    final path = '${directory!.path}/transactions_export.csv';
    final file = File(path);

    await file.writeAsString(csvData);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Exporté dans : $path")),
    );
  }

  Future<void> _importFromCSV(BuildContext context) async {
    final status = await Permission.storage.request();

    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Permission refusée")),
      );
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result == null) return;

    final file = File(result.files.single.path!);
    final content = await file.readAsString();
    final rows = const CsvToListConverter().convert(content, eol: "\n");

    if (rows.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Fichier CSV vide ou invalide.")),
      );
      return;
    }

    int imported = 0;

    for (int i = 1; i < rows.length; i++) {
      final row = rows[i];

      try {
        final transaction = Transaction.fromCSV(row);
        await TransactionDatabase.instance.insertTransaction(transaction);
        imported++;
      } catch (e) {
        print("Erreur à la ligne ${i + 1} : $e");
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Importation terminée : $imported transactions ajoutées.")),
    );
  }

  void _confirmReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Confirmer"),
        content: Text("Voulez-vous vraiment supprimer toutes les transactions ?"),
        actions: [
          TextButton(
            child: Text("Annuler"),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: Text("Oui", style: TextStyle(color: Colors.red)),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await TransactionDatabase.instance.deleteAllTransactions();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Toutes les transactions ont été supprimées.")),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          leading: Icon(Icons.color_lens),
          title: Text('Mode sombre'),
          trailing: Switch(
            value: Theme.of(context).brightness == Brightness.dark,
            onChanged: (val) {
              // Connecte ce switch à ton ThemeProvider si nécessaire
            },
          ),
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.upload_file),
          title: Text('Exporter les données (.csv)'),
          onTap: () => _exportToCSV(context),
        ),
        ListTile(
          leading: Icon(Icons.download),
          title: Text('Importer les données (.csv)'),
          onTap: () => _importFromCSV(context),
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.delete_forever, color: Colors.red),
          title: Text('Réinitialiser toutes les données'),
          onTap: () => _confirmReset(context),
        ),
      ],
    );
  }
}
