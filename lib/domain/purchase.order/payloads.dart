

class PurchaseOrderUpdatePayload {
  DateTime date;
  PurchaseOrderUpdatePayload({required this.date});

  Map<String, dynamic> toMap() {
    return {
      'date': date.toUtc().toIso8601String(),
    };
  }

  factory PurchaseOrderUpdatePayload.create({required DateTime date}) {
    return PurchaseOrderUpdatePayload(date: date);
  }
}
