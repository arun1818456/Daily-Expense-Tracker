import 'package:intl/intl.dart';

import '../exports.dart';
import '../mixin/base_class.dart';

class TodayExpenseCard extends StatelessWidget with BaseClass {
  const TodayExpenseCard({super.key, required this.expense});
 final Expense expense;
  @override
  Widget build(BuildContext context) {
    return  Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: getCategoryColor(expense.category),
          child: Text(
            expense.category.emoji,
            style: const TextStyle(fontSize: 20),
          ),
        ),
        title: Text(expense.title),
        subtitle: Text(
          '${expense.category.displayName} • ${DateFormat('HH:mm').format(expense.date)}',
        ),
        trailing: Text(
          '₹ ${expense.amount.toStringAsFixed(2)}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}
