import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AmountText extends StatelessWidget {
  final double amount;
  final TextStyle? style;
  const AmountText(this.amount, {super.key, this.style});

  @override
  Widget build(BuildContext context) {
    return Text(_formatCurrency(amount), style: style);
  }

  String _formatCurrency(double amount) {
    var formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    String formattedAmount = formatter.format(amount.abs());
    if (amount < 0) {
      formattedAmount = '-$formattedAmount';
    }
    return formattedAmount;
  }
}
