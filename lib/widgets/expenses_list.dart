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
    return expenses.isEmpty
        ? Center(
            child: Text(
              'No expenses added yet!',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          )
        : ListView.builder(
            itemCount: expenses.length,
            itemBuilder: (ctx, index) => Dismissible(
              key: ValueKey(expenses[index].id),
              background: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.error,
                  borderRadius: BorderRadius.circular(5),
                ),
                margin: EdgeInsets.symmetric(
                  horizontal:
                      Theme.of(context).cardTheme.margin?.horizontal ?? 0,
                ),
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                child: const Icon(
                  Icons.delete,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              direction: DismissDirection.endToStart,
              onDismissed: (direction) {
                onRemoveExpense(expenses[index]);
              },
              confirmDismiss: (direction) async {
                final shouldDelete = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Delete Expense'),
                    content: const Text(
                        'Are you sure you want to remove this expense?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
                return shouldDelete ?? false;
              },
              child: ExpenseItem(expenses[index]),
            ),
          );
  }
}
