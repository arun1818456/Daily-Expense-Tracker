import 'package:uuid/uuid.dart';

enum ExpenseCategory {
  food,
  transportation,
  entertainment,
  shopping,
  health,
  utilities,
  vegetables,
  other,
}

class Expense {
  final String id;
  final String title;
  final String paymentType;
  final double amount;
  final ExpenseCategory category;
  final DateTime date;
  final String? description;

  Expense({
    String? id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    required this.paymentType,
    this.description,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category.name,
      'date': date.millisecondsSinceEpoch,
      'description': description,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      paymentType: map['type'],
      category: ExpenseCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => ExpenseCategory.other,
      ),
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      description: map['description'],
    );
  }

  Expense copyWith({
    String? id,
    String? title,
    double? amount,
    ExpenseCategory? category,
    DateTime? date,
    String? description,
    String? paymentType,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      description: description ?? this.description,
      paymentType: paymentType?? this.paymentType,
    );
  }
}

extension ExpenseCategoryExtension on ExpenseCategory {
  String get displayName {
    switch (this) {
      case ExpenseCategory.food:
        return 'Food';
      case ExpenseCategory.transportation:
        return 'Transportation';
      case ExpenseCategory.entertainment:
        return 'Entertainment';
      case ExpenseCategory.shopping:
        return 'Shopping';
      case ExpenseCategory.health:
        return 'Health';
      case ExpenseCategory.utilities:
        return 'Utilities';
      case ExpenseCategory.vegetables:
        return 'Vegetables';
      case ExpenseCategory.other:
        return 'Other';
    }
  }

  String get emoji {
    switch (this) {
      case ExpenseCategory.food:
        return '🍽️';
      case ExpenseCategory.transportation:
        return '🚗';
      case ExpenseCategory.entertainment:
        return '🎬';
      case ExpenseCategory.shopping:
        return '🛒';
      case ExpenseCategory.health:
        return '🏥';
      case ExpenseCategory.utilities:
        return '💡';
      case ExpenseCategory.vegetables:
        return '🥦';
      case ExpenseCategory.other:
        return '📝';
    }
  }
}
