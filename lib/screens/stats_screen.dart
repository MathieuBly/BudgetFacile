import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../db/transaction_database.dart';
import '../models/transaction.dart';
import 'dart:math';

class StatsScreen extends StatefulWidget {
  @override
  _StatsScreenState createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  List<Transaction> _transactions = [];
  bool _showIncome = false; // false = dépenses, true = revenus

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await TransactionDatabase.instance.getAllTransactions();
    setState(() {
      _transactions = data;
    });
  }

  Map<String, double> getCategoryTotals() {
    final Map<String, double> categorySums = {};
    for (var txn in _transactions) {
      if (txn.isIncome == _showIncome) {
        categorySums[txn.category] = (categorySums[txn.category] ?? 0) + txn.amount;
      }
    }
    return categorySums;
  }

  List<Color> _generateColors(int count) {
    final random = Random();
    return List.generate(
      count,
      (_) => Color.fromARGB(
        255,
        random.nextInt(200),
        random.nextInt(200),
        random.nextInt(200),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalIncome = _transactions
        .where((t) => t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);

    final totalExpense = _transactions
        .where((t) => !t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);

    final balance = totalIncome - totalExpense;

    final categoryData = getCategoryTotals();

    if (categoryData.isEmpty) {
      return Center(child: Text("Aucune donnée à afficher."));
    }

    final colors = _generateColors(categoryData.length);
    final total = categoryData.values.fold(0.0, (a, b) => a + b);

    final sections = categoryData.entries.mapIndexed((index, entry) {
      final value = entry.value;
      final percentage = ((value / total) * 100).toStringAsFixed(1);

      return PieChartSectionData(
        color: colors[index],
        value: value,
        title: "$percentage%",
        radius: 80,
        titleStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Column(
      children: [
        SizedBox(height: 16),
        // ✅ Résumé financier
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              Text(
                "Résumé financier",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text("Revenus", style: TextStyle(color: Colors.green)),
                      Text("€${totalIncome.toStringAsFixed(2)}"),
                    ],
                  ),
                  Column(
                    children: [
                      Text("Dépenses", style: TextStyle(color: Colors.red)),
                      Text("€${totalExpense.toStringAsFixed(2)}"),
                    ],
                  ),
                  Column(
                    children: [
                      Text("Solde", style: TextStyle(color: Colors.blue)),
                      Text("€${balance.toStringAsFixed(2)}"),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        // ✅ Switch revenus / dépenses
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Dépenses"),
            Switch(
              value: _showIncome,
              onChanged: (val) {
                setState(() {
                  _showIncome = val;
                });
              },
            ),
            Text("Revenus"),
          ],
        ),
        Text(
          _showIncome ? "Répartition des revenus" : "Répartition des dépenses",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        // ✅ Camembert
        SizedBox(
          height: 250,
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 40,
              sectionsSpace: 4,
            ),
          ),
        ),
        SizedBox(height: 16),
        // ✅ Liste légende des catégories
        Expanded(
          child: ListView.builder(
            itemCount: categoryData.length,
            itemBuilder: (context, index) {
              final category = categoryData.keys.elementAt(index);
              final amount = categoryData[category]!;
              final percent = ((amount / total) * 100).toStringAsFixed(1);

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: colors[index],
                  radius: 10,
                ),
                title: Text(category),
                trailing: Text("€${amount.toStringAsFixed(2)} ($percent%)"),
              );
            },
          ),
        ),
      ],
    );
  }
}

// Extension utilitaire : map avec index
extension MapIndexed<E> on Iterable<E> {
  Iterable<T> mapIndexed<T>(T Function(int index, E item) f) {
    var index = 0;
    return map((e) => f(index++, e));
  }
}
