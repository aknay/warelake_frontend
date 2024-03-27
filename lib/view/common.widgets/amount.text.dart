import 'package:flutter/material.dart';

class AmountText extends StatelessWidget {
  final double amount;
  final TextStyle? style;
  const AmountText(this.amount, {super.key, this.style});

  @override
  Widget build(BuildContext context) {
    String formattedValue = amount.toStringAsFixed(2);
    return Text(formattedValue, style: style);
  }
}
