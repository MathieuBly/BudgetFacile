import 'package:flutter/material.dart';
import '../db/transaction_database.dart';
import '../models/transaction.dart';

class TransactionListScreen extends StatefulWidget {
  @override
  _TransactionListScreenState createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  late Future<List<Transaction>> _transactions;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  void _loadTransactions() {
    setState(() {
      _transactions = TransactionDatabase.instance.getAllTransactions();
    });
  }

  Future<void> _refresh() async {
    _loadTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Transaction>>(
      future: _transactions,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              children: [Center(child: Padding(
                padding: const EdgeInsets.only(top: 100),
                child: Text("Aucune transaction enregistrée."),
              ))],
            ),
          );
        }

        final transactions = snapshot.data!;

        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView.builder(
            physics: AlwaysScrollableScrollPhysics(),
            itemCount: transactions.length,
            itemBuilder: (ctx, index) {
              final txn = transactions[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: Icon(
                    txn.isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                    color: txn.isIncome ? Colors.green : Colors.red,
                  ),
                  title: Text(txn.title),
                  subtitle: Text(
                      '${txn.category} • ${txn.date.day}/${txn.date.month}/${txn.date.year}'),
                  trailing: Text(
                    '${txn.isIncome ? '+' : '-'} ${txn.amount.toStringAsFixed(2)} €',
                    style: TextStyle(
                      color: txn.isIncome ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
