import 'dart:io';
import 'dart:ui';
import 'package:alarm/alarm.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/expense.dart';
import '../services/database_services.dart';
import '../services/notification_services.dart';

final expensesProvider = StateNotifierProvider<ExpenseNotifier, List<Expense>>((
  ref,
) {
  return ExpenseNotifier();
});

// Provider for today's expenses
final todayExpensesProvider = Provider<List<Expense>>((ref) {
  final expenses = ref.watch(expensesProvider);
  final today = DateTime.now();
  final startOfDay = DateTime(today.year, today.month, today.day);
  final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

  final todayExpenses = expenses.where((expense) {
    return expense.date.isAfter(startOfDay) && expense.date.isBefore(endOfDay);
  }).toList();
  // Sort by date descending (latest first)
  todayExpenses.sort((a, b) => b.date.compareTo(a.date));
  return todayExpenses;
});

// Provider for this month's expenses
final monthlyExpensesProvider = Provider<List<Expense>>((ref) {
  final expenses = ref.watch(expensesProvider);
  final now = DateTime.now();
  final startOfMonth = DateTime(now.year, now.month, 1);
  final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

  return expenses.where((expense) {
    return expense.date.isAfter(startOfMonth) &&
        expense.date.isBefore(endOfMonth);
  }).toList();
});

// Provider for total amounts
final totalExpensesProvider = Provider<Map<String, double>>((ref) {
  final todayExpenses = ref.watch(todayExpensesProvider);
  final monthlyExpenses = ref.watch(monthlyExpensesProvider);

  double todayTotal = todayExpenses.fold(
    0.0,
    (sum, expense) => sum + expense.amount,
  );
  double monthlyTotal = monthlyExpenses.fold(
    0.0,
    (sum, expense) => sum + expense.amount,
  );

  return {'today': todayTotal, 'monthly': monthlyTotal};
});

// Provider for category-wise expenses
final categoryExpensesProvider = Provider<Map<ExpenseCategory, double>>((ref) {
  final monthlyExpenses = ref.watch(monthlyExpensesProvider);
  Map<ExpenseCategory, double> categoryTotals = {};

  for (var expense in monthlyExpenses) {
    categoryTotals[expense.category] =
        (categoryTotals[expense.category] ?? 0.0) + expense.amount;
  }

  return categoryTotals;
});

// Provider for persistent notification state
final persistentNotificationProvider =
    StateNotifierProvider<PersistentNotificationNotifier, bool>((ref) {
      return PersistentNotificationNotifier();
    });

// Provider for daily reminder state
final dailyReminderProvider =
    StateNotifierProvider<DailyReminderNotifier, bool>((ref) {
      return DailyReminderNotifier();
    });

class ExpenseNotifier extends StateNotifier<List<Expense>> {
  ExpenseNotifier() : super([]) {
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    final expenses = await DatabaseService.getAllExpenses();
    state = expenses;
  }

  Future<void> addExpense(Expense expense) async {
    await DatabaseService.insertExpense(expense);
    final updatedList = [...state, expense];
    updatedList.sort((a, b) => b.date.compareTo(a.date));
    state = updatedList;
    await NotificationService.showExpenseAddedNotification(
      expense.title,
      expense.amount,
    );
  }

  Future<void> updateExpense(Expense expense) async {
    await DatabaseService.updateExpense(expense);
    state = state.map((e) => e.id == expense.id ? expense : e).toList();
  }

  Future<void> deleteExpense(String id) async {
    await DatabaseService.deleteExpense(id);
    state = state.where((expense) => expense.id != id).toList();
  }

  Future<void> loadExpensesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final expenses = await DatabaseService.getExpensesByDateRange(
      startDate,
      endDate,
    );
    state = expenses;
  }
}

class PersistentNotificationNotifier extends StateNotifier<bool> {
  PersistentNotificationNotifier() : super(false) {
    _loadState();
  }

  Future<void> _loadState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Object? value = prefs.get("persistent");
    state = value == null ? false : value as bool;
  }

  Future<void> toggle() async {
    if (state) {
      await NotificationService.hidePersistentNotification();
    } else {
      await NotificationService.showPersistentNotification();
    }
    final newState = !state;
    state = newState;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("persistent", newState);
  }
}

class DailyReminderNotifier extends StateNotifier<bool> {
  DailyReminderNotifier() : super(false) {
    _loadState();
  }

  Future<void> _loadState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Object? value = prefs.get("reminder");
    state = value == null ? false : value as bool;
  }

  Future<void> toggle() async {
    if (state) {
      await Alarm.stop(42);
    } else {
      await setDaily8PMAlarm();
    }

    final newState = !state;
    state = newState;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("reminder", newState);
  }

  Future<void> setDaily8PMAlarm() async {
    final now = DateTime.now();

    final DateTime next8PM =
        DateTime(
          now.year,
          now.month,
          now.day,
          20, // 8 PM
        ).isBefore(now)
        ? DateTime(now.year, now.month, now.day + 1, 20)
        : DateTime(now.year, now.month, now.day, 20);

    final alarmSettings = AlarmSettings(
      id: 42,
      dateTime: next8PM,
      assetAudioPath: 'assets/alarm.mp3',
      loopAudio: true,
      vibrate: true,
      warningNotificationOnKill: Platform.isIOS,
      androidFullScreenIntent: true,
      volumeSettings: VolumeSettings.fade(
        volume: 0.8,
        fadeDuration: Duration(seconds: 5),
        volumeEnforced: true,
      ),
      notificationSettings: const NotificationSettings(
        title: 'Daily Reminder',
        body: 'It\'s 8 PM! Time to track your expenses.',
        stopButton: 'Stop',
        icon: 'notification_icon',
        iconColor: Color(0xff862778),
      ),
    );
    await Alarm.set(alarmSettings: alarmSettings);
  }
}
