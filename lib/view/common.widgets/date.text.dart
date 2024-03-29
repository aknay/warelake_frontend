import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateText extends StatelessWidget {
  final DateTime date;
  final TextStyle? style;
  const DateText(this.date, {super.key, this.style});

  @override
  Widget build(BuildContext context) {
    var locale = Localizations.localeOf(context);
    var formattedDate = DateFormat.yMMMd(locale.toString()).format(date);
    return Text(
      formattedDate,
      style: style,
    );
  }
}
