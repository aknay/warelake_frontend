import 'package:intl/intl.dart';

class PurchaseOrderUpdatePayload {
  DateTime date;
  PurchaseOrderUpdatePayload({required this.date});

  Map<String, dynamic> toMap() {
    return {
      'date': DateFormat('yyyy-MM-dd').format(date),
    };
  }

  factory PurchaseOrderUpdatePayload.create({required DateTime date}) {
    return PurchaseOrderUpdatePayload(date: date);
  }
}
