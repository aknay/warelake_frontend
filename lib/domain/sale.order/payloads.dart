import 'package:intl/intl.dart';

class SaleOrderUpdatePayload {
  DateTime date;
  SaleOrderUpdatePayload({required this.date});

  Map<String, dynamic> toMap() {
    return {
      'date': DateFormat('yyyy-MM-dd').format(date),
    };
  }

  factory SaleOrderUpdatePayload.create({required DateTime date}) {
    return SaleOrderUpdatePayload(date: date);
  }
}
