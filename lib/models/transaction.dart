import 'package:flutter/foundation.dart';

class Transaction {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String category;
  final bool isIncome;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    required this.isIncome,
  });

  /// Conversion pour SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'category': category,
      'isIncome': isIncome ? 1 : 0,
    };
  }

  /// Création à partir de la base de données
  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
      category: map['category'],
      isIncome: map['isIncome'] == 1,
    );
  }

  /// Création à partir d’une ligne CSV
  factory Transaction.fromCSV(List<dynamic> row) {
    final typeValue = row[5].toString().trim().toLowerCase();
    return Transaction(
      id: row[0].toString(),
      title: row[1].toString(),
      amount: double.tryParse(row[2].toString()) ?? 0.0,
      date: DateTime.parse(row[3].toString()),
      category: row[4].toString(),
      isIncome: typeValue.contains('revenu'),
    );
  }

  /// Conversion vers une ligne CSV
  List<dynamic> toCSV() {
    return [
      id,
      title,
      amount.toStringAsFixed(2),
      date.toIso8601String(),
      category,
      isIncome ? 'Revenu' : 'Dépense',
    ];
  }
}
