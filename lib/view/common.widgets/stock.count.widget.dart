import 'package:flutter/material.dart';

class StockCount extends StatelessWidget {
  final double amount;
  final TextStyle? style;

  const StockCount({
    super.key,
    required this.amount,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    String formattedValue = amount.toStringAsFixed(2);

    return Text(formattedValue, style: style);
  }
}
