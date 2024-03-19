import 'package:flutter/material.dart';
import 'package:warelake/data/currency.code/valueobject.dart';

class CurrencyAmountText extends StatelessWidget {
  final double amount;
  final CurrencyCode currencyCode;
  final TextStyle? style;
  const CurrencyAmountText( {super.key, required this.amount, required this.currencyCode, this.style});

  @override
  Widget build(BuildContext context) {
    String formattedValue = amount.toStringAsFixed(2);
    return Text("${currencyCode.name} $formattedValue"  , style: style);
  }
}
