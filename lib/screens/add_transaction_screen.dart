import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../db/transaction_database.dart';
import '../models/transaction.dart';

class AddTransactionScreen extends StatefulWidget {
  @override
  _AddTransactionScreenState createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  bool _isIncome = false;
  String _selectedCategory = "Autre";
  DateTime _selectedDate = DateTime.now(); // ✅ Date choisie

  final List<String> _categories = [
    "Salaire",
    "Courses",
    "Transport",
    "Loisir",
    "Autre"
  ];

  Future<void> _saveTransaction() async {
    if (_formKey.currentState!.validate()) {
      final newTransaction = Transaction(
        id: Uuid().v4(),
        title: _titleController.text,
        amount: double.parse(_amountController.text),
        date: _selectedDate, // ✅ Enregistrement de la vraie date
        category: _selectedCategory,
        isIncome: _isIncome,
      );

      await TransactionDatabase.instance.insertTransaction(newTransaction);
      Navigator.of(context).pop(); // Revenir à la page précédente
    }
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Ajouter une transaction")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: "Titre"),
                validator: (value) =>
                    value!.isEmpty ? "Champ requis" : null,
              ),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Montant"),
                validator: (value) =>
                    value!.isEmpty ? "Champ requis" : null,
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: _categories
                    .map((cat) => DropdownMenuItem(
                          child: Text(cat),
                          value: cat,
                        ))
                    .toList(),
                onChanged: (val) => setState(() {
                  _selectedCategory = val!;
                }),
                decoration: InputDecoration(labelText: "Catégorie"),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Date : ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                    ),
                  ),
                  TextButton(
                    onPressed: _pickDate,
                    child: Text("Choisir la date"),
                  ),
                ],
              ),
              SwitchListTile(
                title: Text("Est-ce un revenu ?"),
                value: _isIncome,
                onChanged: (val) => setState(() => _isIncome = val),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveTransaction,
                child: Text("Ajouter la transaction"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
