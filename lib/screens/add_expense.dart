import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  final Expense? expenseToEdit;

  const AddExpenseScreen({super.key, this.expenseToEdit});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  PaymentType? _selectedPaymentType;

  ExpenseCategory _selectedCategory = ExpenseCategory.other;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    if (widget.expenseToEdit != null) {
      _titleController.text = widget.expenseToEdit!.title;
      _amountController.text = widget.expenseToEdit!.amount.toString();
      _descriptionController.text = widget.expenseToEdit!.description ?? '';
      _selectedCategory = widget.expenseToEdit!.category;
      _selectedDate = widget.expenseToEdit!.date;
      _selectedPaymentType = PaymentType.values.firstWhere(
        (type) => type.name == widget.expenseToEdit!.paymentType,
      );
    } else {
      addData();
    }
  }

  addData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? savedPaymentType = prefs.getString('paymentType');
    if (savedPaymentType != null) {
      _selectedPaymentType = PaymentType.values.firstWhere(
        (type) => type.name == savedPaymentType,
      );
      setState(() {});
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final expense = Expense(
        id: widget.expenseToEdit?.id,
        title: _titleController.text.trim(),
        amount: double.parse(_amountController.text),
        category: _selectedCategory,
        date: _selectedDate,
        paymentType: _selectedPaymentType!.name,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
      );

      if (widget.expenseToEdit != null) {
        await ref.read(expensesProvider.notifier).updateExpense(expense);
      } else {
        await ref.read(expensesProvider.notifier).addExpense(expense);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.expenseToEdit != null
                  ? 'Expense updated successfully!'
                  : 'Expense added successfully!',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
      );

      if (time != null) {
        setState(() {
          _selectedDate = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.expenseToEdit != null ? 'Edit Expense' : 'Add Expense',
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (widget.expenseToEdit != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _showDeleteConfirmation(),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Field
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Amount Field
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.currency_rupee),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  if (double.parse(value) <= 0) {
                    return 'Amount must be greater than 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Payment Type Dropdown
              DropdownButtonFormField<PaymentType>(
                initialValue: _selectedPaymentType,
                decoration: const InputDecoration(
                  labelText: 'Payment Type',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                ),
                items: PaymentType.values.map((type) {
                  return DropdownMenuItem<PaymentType>(
                    value: type,
                    child: Row(
                      children: [
                        Icon(type.icon, size: 20),
                        const SizedBox(width: 8),
                        Text(type.label),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) async {
                  setState(() {
                    _selectedPaymentType = value!;
                  });
                  final SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.setString('paymentType', value!.name);
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select payment type';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Category Selection
              Text('Category', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ExpenseCategory.values.map((category) {
                  final isSelected = _selectedCategory == category;
                  return FilterChip(
                    selected: isSelected,
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(category.emoji),
                        const SizedBox(width: 4),
                        Text(category.displayName),
                      ],
                    ),
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Date Selection
              Card(
                child: ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Date & Time'),
                  subtitle: Text(
                    DateFormat('MMM dd, yyyy HH:mm').format(_selectedDate),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: _selectDate,
                ),
              ),
              const SizedBox(height: 16),

              // Description Field
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveExpense,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : Text(
                          widget.expenseToEdit != null
                              ? 'Update Expense'
                              : 'Add Expense',
                          style: const TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Expense'),
        content: const Text('Are you sure you want to delete this expense?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref
                  .read(expensesProvider.notifier)
                  .deleteExpense(widget.expenseToEdit!.id);
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Expense deleted successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

enum PaymentType { cash, online }

extension PaymentTypeX on PaymentType {
  String get label {
    switch (this) {
      case PaymentType.cash:
        return 'Cash';
      case PaymentType.online:
        return 'Online';
    }
  }

  IconData get icon {
    switch (this) {
      case PaymentType.cash:
        return Icons.money;
      case PaymentType.online:
        return Icons.account_balance_wallet;
    }
  }
}
