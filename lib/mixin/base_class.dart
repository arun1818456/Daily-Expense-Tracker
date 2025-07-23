import '../exports.dart';

mixin BaseClass {
  Color getCategoryColor(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.food:
        return Colors.orange;
      case ExpenseCategory.transportation:
        return Colors.blue;
      case ExpenseCategory.entertainment:
        return Colors.purple;
      case ExpenseCategory.shopping:
        return Colors.pink;
      case ExpenseCategory.health:
        return Colors.red;
      case ExpenseCategory.utilities:
        return Colors.teal;
      case ExpenseCategory.other:
        return Colors.grey;
    }
  }
}
