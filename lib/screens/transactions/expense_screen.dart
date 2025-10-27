import 'package:flutter/material.dart';
import 'transaction_list_screen.dart';

class ExpenseScreen extends StatelessWidget {
  const ExpenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TransactionListScreen(title: 'Expense');
  }
}