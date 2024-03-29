import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateText extends StatelessWidget {
  final DateTime date;
  final TextStyle? style;
  final bool enableTime;
  const DateText(this.date, {super.key, this.style, this.enableTime = false});

  @override
  Widget build(BuildContext context) {
    var locale = Localizations.localeOf(context);
    var formattedDate = enableTime ?  DateFormat('MMM dd, yyyy hh:mm a').format(date)
: DateFormat.yMMMd(locale.toString()).format(date);
    return Text(
      formattedDate,
      style: style,
    );
  }
}
