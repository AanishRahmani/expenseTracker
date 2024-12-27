import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

final formatter = DateFormat.yMd();
const uuid = Uuid();

enum Category {
  food,
  travel,
  leisure,
  work,
}

const categoryIcon = {
  Category.food: Icons.lunch_dining,
  Category.travel: Icons.flight_takeoff,
  Category.leisure: Icons.movie_filter,
  Category.work: Icons.work,
};

class Expense {
  Expense({
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
  }) : id = uuid.v4();

  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final Category category;

  String get formatDate {
    return formatter.format(date);
  }

  // Expense to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'category': category.index, // Store enum as index
    };
  }

  // Create Expense from JSON
  static Expense fromJson(Map<String, dynamic> json) {
    return Expense(
      title: json['title'],
      amount: json['amount'],
      date: DateTime.parse(json['date']),
      category: Category.values[json['category']],
    );
  }
}

class ExpenseBucket {
  const ExpenseBucket({
    required this.category,
    required this.expenses,
  });

  ExpenseBucket.forCategory(List<Expense> allExpenses, this.category)
      : expenses = allExpenses
            .where((expense) => expense.category == category)
            .toList();

  final Category category;
  final List<Expense> expenses;

  double get totalExp {
    double sum = 0;
    for (final expense in expenses) {
      sum += expense.amount;
    }
    return sum;
  }
}

class ExpenseManager {
  static const _storageKey = 'expenses';

  // Save expenses to SharedPreferences
  static Future<void> saveExpenses(List<Expense> expenses) async {
    final prefs = await SharedPreferences.getInstance();
    final expenseList = expenses.map((expense) => expense.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(expenseList));
  }

  // Load expenses from SharedPreferences
  static Future<List<Expense>> loadExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final expenseString = prefs.getString(_storageKey);

    if (expenseString == null) {
      return [];
    }

    final decodedList = jsonDecode(expenseString) as List<dynamic>;
    return decodedList.map((json) => Expense.fromJson(json)).toList();
  }

  // Clear all saved expenses
  static Future<void> clearExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  // Create a new expense
  static Expense createNewExpense({
    required String title,
    required double amount,
    required DateTime date,
    required Category category,
  }) {
    return Expense(
      title: title,
      amount: amount,
      date: date,
      category: category,
    );
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Expenses(),
    );
  }
}

class Expenses extends StatefulWidget {
  const Expenses({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ExpenseState();
  }
}

class _ExpenseState extends State<Expenses> {
  List<Expense> _registeredExpenses = [];

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  // Load expenses from SharedPreferences
  void _loadExpenses() async {
    final loadedExpenses = await ExpenseManager.loadExpenses();
    setState(() {
      _registeredExpenses = loadedExpenses;
    });
  }

  // Add expense to the list
  void _addExpense(Expense expense) {
    setState(() {
      _registeredExpenses.add(expense);
    });
    ExpenseManager.saveExpenses(_registeredExpenses);
  }

  // Remove expense from the list
  void _removeExpense(Expense expense) {
    setState(() {
      _registeredExpenses.remove(expense);
    });
    ExpenseManager.saveExpenses(_registeredExpenses);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              final newExpense = ExpenseManager.createNewExpense(
                title: 'New Expense',
                amount: 10.0,
                date: DateTime.now(),
                category: Category.food,
              );
              _addExpense(newExpense);
            },
            child: const Text('Add Expense'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _registeredExpenses.length,
              itemBuilder: (ctx, index) {
                final expense = _registeredExpenses[index];
                return ListTile(
                  title: Text(expense.title),
                  subtitle: Text('Rs ${expense.amount.toStringAsFixed(2)}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _removeExpense(expense),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
