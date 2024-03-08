import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:warelake/domain/valueobject.dart';

part 'entities.freezed.dart';

typedef Timestamp = int;

@freezed
class MonthlyOrderSummary with _$MonthlyOrderSummary {
  const factory MonthlyOrderSummary({
    required String id,
    required int month,
    required int year,
    required int saleOrderCount,
    required int saleOrderMilliAmount,
    required int purchaseOrderCount,
    required int purchaseOrderMilliAmount,
  }) = _MonthlyOrderSummary;

  const MonthlyOrderSummary._();

  factory MonthlyOrderSummary.fromJson(Map<String, dynamic> json) {
    final id = json["id"];
    int purchaseOrderCount = json['purchase_order_count'];
    int purchaseOrderMilliAmount = json['purchase_order_amount'];
    int saleOrderCount = json['sale_order_count'];
    int saleOrderIncome = json['sale_order_amount'];
    int month = json['month'];
    int year = json['year'];

    return MonthlyOrderSummary(
        id: id,
        month: month,
        year: year,
        purchaseOrderCount: purchaseOrderCount,
        purchaseOrderMilliAmount: purchaseOrderMilliAmount,
        saleOrderCount: saleOrderCount,
        saleOrderMilliAmount: saleOrderIncome);
  }

  Amount get saleOrderAmount => (saleOrderMilliAmount / 1000);
  Amount get purchaseOrderAmount => (purchaseOrderMilliAmount / 1000);
}
