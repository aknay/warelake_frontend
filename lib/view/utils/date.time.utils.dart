import 'package:intl/intl.dart';

extension RemoveSeconds on DateTime {
  DateTime removeTime() {
    return DateTime(year, month, day);
  }
}

String formatDate(DateTime dt) {
  final now = DateTime.now();
  if (dt.day == now.day && dt.month == now.month && dt.year == now.year) {
    return 'Today';
  }

  return DateFormat('d MMM yyyy').format(dt);
}
