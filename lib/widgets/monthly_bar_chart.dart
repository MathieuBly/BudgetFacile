import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/transaction.dart';
import 'package:intl/intl.dart';

class MonthlyBarChart extends StatelessWidget {
  final List<Transaction> transactions;

  MonthlyBarChart({required this.transactions});

  Map<String, Map<String, double>> _aggregateByMonth() {
    Map<String, Map<String, double>> data = {};

    for (var txn in transactions) {
      String month = DateFormat('MMM yyyy').format(txn.date);

      if (!data.containsKey(month)) {
        data[month] = {'income': 0, 'expense': 0};
      }

      if (txn.isIncome) {
        data[month]!['income'] = data[month]!['income']! + txn.amount;
      } else {
        data[month]!['expense'] = data[month]!['expense']! + txn.amount;
      }
    }

    return data;
  }

  @override
  Widget build(BuildContext context) {
    final monthlyData = _aggregateByMonth();
    final months = monthlyData.keys.toList();

    return SizedBox(
      height: 300,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          barGroups: months.asMap().entries.map((entry) {
            final index = entry.key;
            final month = entry.value;
            final income = monthlyData[month]!['income']!;
            final expense = monthlyData[month]!['expense']!;

            return BarChartGroupData(x: index, barRods: [
              BarChartRodData(
                  fromY: income,
                  width: 8,
                  color: Colors.green, toY: income),
              BarChartRodData(
                  fromY: expense,
                  width: 8,
                  color: Colors.red, toY: expense),
            ]);
          }).toList(),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, meta) {
                  final index = value.toInt();
                  if (index < months.length) {
                    return Text(months[index], style: TextStyle(fontSize: 10));
                  }
                  return Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true),
            ),
          ),
        ),
      ),
    );
  }
}
