

class SaleOrderUpdatePayload {
  DateTime date;
  SaleOrderUpdatePayload({required this.date});

  Map<String, dynamic> toMap() {
    return {
      'date': date.toUtc().toIso8601String(),
    };
  }

  factory SaleOrderUpdatePayload.create({required DateTime date}) {
    return SaleOrderUpdatePayload(date: date);
  }
}
