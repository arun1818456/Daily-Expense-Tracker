import 'package:intl/intl.dart';
import 'package:river/mixin/base_class.dart';
import 'package:river/screens/graph_screen.dart';
import 'package:river/widgets/all_expenses_card_widget.dart';
import '../exports.dart';

class ExpenseListScreen extends ConsumerStatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  ConsumerState<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends ConsumerState<ExpenseListScreen>
    with BaseClass {
  String _selectedFilter = 'All';
  final List<String> _filterOptions = [
    'All',
    'Today',
    'This Week',
    'This Month',
  ];

  @override
  Widget build(BuildContext context) {
    final expenses = ref.watch(expensesProvider);
    final filteredExpenses = _getFilteredExpenses(expenses);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('All Expenses'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedFilter = value;
              });
            },
            itemBuilder: (context) => _filterOptions.map((option) {
              return PopupMenuItem<String>(
                value: option,
                child: Row(
                  children: [
                    Icon(
                      _selectedFilter == option
                          ? Icons.check
                          : Icons.filter_list,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(option),
                  ],
                ),
              );
            }).toList(),
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Summary
          InkWell(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return GraphScreen();
              },));
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).colorScheme.surfaceVariant,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$_selectedFilter (${filteredExpenses.length} expenses)',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    'Total: ₹ ${_getTotalAmount(filteredExpenses).toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Expense List
          Expanded(
            child: filteredExpenses.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No expenses found',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add your first expense to get started',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 45),
                    itemCount: filteredExpenses.length,
                    itemBuilder: (context, index) {
                      final expense = filteredExpenses[index];
                      return Column(
                        children: [
                          getDateTitle(filteredExpenses, index,),
                          AllExpensesCardWidget(expense: expense),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddExpenseScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  List<Expense> _getFilteredExpenses(List<Expense> expenses) {
    final now = DateTime.now();

    switch (_selectedFilter) {
      case 'Today':
        final startOfDay = DateTime(now.year, now.month, now.day);
        final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
        return expenses.where((expense) {
          return expense.date.isAfter(startOfDay) &&
              expense.date.isBefore(endOfDay);
        }).toList();

      case 'This Week':
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final startOfWeekDay = DateTime(
          startOfWeek.year,
          startOfWeek.month,
          startOfWeek.day,
        );
        return expenses.where((expense) {
          return expense.date.isAfter(startOfWeekDay);
        }).toList();

      case 'This Month':
        final startOfMonth = DateTime(now.year, now.month, 1);
        return expenses.where((expense) {
          return expense.date.isAfter(startOfMonth);
        }).toList();

      default:
        return expenses;
    }
  }

  double _getTotalAmount(List<Expense> expenses) {
    return expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  Widget getDateTitle(List<Expense> expenses, int index) {
    final DateTime now = DateTime.now();
    final DateTime messageDate = expenses[index].date;

    String dateKey;
    if (messageDate.year == now.year &&
        messageDate.month == now.month &&
        messageDate.day == now.day) {
      dateKey = 'Today';
    } else if (messageDate.year == now.year &&
        messageDate.month == now.month &&
        messageDate.day == now.subtract(Duration(days: 1)).day) {
      dateKey = 'Yesterday';
    } else {
      dateKey = DateFormat('dd/MM/yyyy').format(messageDate);
    }

    // Check if it's the first item or the date differs from the previous one
    bool showTitle = index == 0 || !isSameDate(messageDate, expenses[index - 1].date);

    if (showTitle) {
      return Padding(
        padding: const EdgeInsets.only(top: 20.0, bottom: 10),
        child: Text(
          dateKey,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  bool isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

}
