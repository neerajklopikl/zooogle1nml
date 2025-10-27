import 'package:flutter/material.dart';
import 'transaction_list_screen.dart';

class SaleOrderScreen extends StatelessWidget {
  const SaleOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TransactionListScreen(title: 'Sale Order');
  }
}