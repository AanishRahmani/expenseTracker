import 'package:flutter/material.dart';
import 'package:nativeapp/models/expense.dart';
import 'package:nativeapp/widgets/expense_item.dart';

class ExpensesList extends StatelessWidget {
  const ExpensesList({
    super.key,
    required this.expenses,
    required this.onRemoveExpense,
  });

  final List<Expense> expenses;
  final void Function(Expense expense) onRemoveExpense;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: expenses.length,
      itemBuilder: (ctx, index) => Dismissible(
        key: ValueKey(expenses[index]),
        background: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.error,
            borderRadius: BorderRadius.circular(5),
          ),
          margin: EdgeInsets.symmetric(
            horizontal: Theme.of(context).cardTheme.margin?.horizontal ?? 0,
          ),
        ),
        onDismissed: (direction) {
          onRemoveExpense(expenses[index]);
          // Optionally, show a snackbar or other UI to confirm the removal
        },
        child: ExpenseItem(expenses[index]),
      ),
    );
  }
}
