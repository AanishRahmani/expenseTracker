import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:nativeapp/models/expense.dart';
import 'package:nativeapp/widgets/expenses_list.dart';
import 'package:nativeapp/widgets/new_expense.dart';
import 'package:nativeapp/widgets/charts/chart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Expenses extends StatefulWidget {
  const Expenses({super.key});

  @override
  State<Expenses> createState() => _ExpensesState();
}

class _ExpensesState extends State<Expenses> {
  List<Expense> _expenses = [];

  @override
  void initState() {
    super.initState();
    _loadExpenses(); // Load expenses on startup
  }

  // Function to load expenses from SharedPreferences
  Future<void> _loadExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final savedExpenses = prefs.getStringList('expenses') ?? [];
    setState(() {
      _expenses =
          savedExpenses.map((e) => Expense.fromJson(jsonDecode(e))).toList();
    });
  }

  // Function to save expenses to SharedPreferences
  Future<void> _saveExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final expenseData = _expenses.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList('expenses', expenseData);
  }

  // Function to add an expense
  void _addExpense(Expense expense) {
    setState(() {
      _expenses.add(expense);
    });
    _saveExpenses(); // Save updated expenses
  }

  // Function to remove an expense
  void _removeExpense(Expense expense) {
    setState(() {
      _expenses.remove(expense);
    });
    _saveExpenses(); // Save updated expenses
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () {
              setState(() {
                _expenses.clear();
              });
              _saveExpenses(); // Clear saved expenses
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // The chart at the top, fixed
          SizedBox(
            height: 300,
            child: Chart(expenses: _expenses), // Display the chart
          ),

          // The ListView of expenses
          Expanded(
            child: _expenses.isEmpty
                ? const Center(
                    child: Text('No expenses added yet!'),
                  )
                : ExpensesList(
                    expenses: _expenses, // Pass the entire list of expenses
                    onRemoveExpense: _removeExpense,
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _openNewExpenseModal();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _openNewExpenseModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => NewExpense(
        onAddExpense: _addExpense,
      ),
    );
  }
}
