import 'package:river/widgets/category_breakdown_widget.dart';
import '../exports.dart';
import '../mixin/base_class.dart';
import '../widgets/home_summary_card.dart';
import '../widgets/today_expense_card.dart';

class HomeScreen extends ConsumerWidget with BaseClass {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalExpenses = ref.watch(totalExpensesProvider);
    final categoryExpenses = ref.watch(categoryExpensesProvider);
    final todayExpenses = ref.watch(todayExpensesProvider);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Daily Expense Tracker'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Cards
            Row(
              children: [
                Expanded(
                  child: HomeSummaryCard(
                    title: 'Today',
                    amount:
                        '₹ ${totalExpenses['today']?.toStringAsFixed(2) ?? '0.00'}',
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: HomeSummaryCard(
                    title: 'This Month',
                    amount:
                        '₹ ${totalExpenses['monthly']?.toStringAsFixed(2) ?? '0.00'}',
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Today's Expenses
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Today\'s Expenses',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ExpenseListScreen(),
                      ),
                    );
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Today's Expense List
            todayExpenses.isEmpty
                ? Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.receipt_long,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'No expenses today',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: todayExpenses.length,
                    itemBuilder: (context, index) {
                      final expense = todayExpenses[index];
                      return TodayExpenseCard(expense: expense);
                    },
                  ),

            const SizedBox(height: 24),

            // Category Breakdown
            if (categoryExpenses.isNotEmpty) ...[
              Text(
                'Category Breakdown (This Month)',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              ...categoryExpenses.entries.map((entry) {
                final category = entry.key;
                final amount = entry.value;
                final percentage = (amount / totalExpenses['monthly']!) * 100;

                return CategoryBreakdownWidget(
                  category: category,
                  amount: amount,
                  percentage: percentage,
                );
              }),
              const SizedBox(height: 50),
            ],
          ],
        ),
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
}
