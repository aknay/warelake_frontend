import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:warelake/data/currency.code/valueobject.dart';
import 'package:warelake/domain/monthly.order.summary/entities.dart';

part 'entities.freezed.dart';

@freezed
class MonthlyOrderSummaryWithCurrency with _$MonthlyOrderSummaryWithCurrency {
  const factory MonthlyOrderSummaryWithCurrency({
    required int saleOrderCount,
    required double saleOrderAmount,
    required int purchaseOrderCount,
    required double purchaseOrderAmount,
    required CurrencyCode currencyCode,
  }) = _MonthlyOrderSummaryWithCurrency;

  const MonthlyOrderSummaryWithCurrency._();

  factory MonthlyOrderSummaryWithCurrency.from(MonthlyOrderSummary monthlyOrderSummary, CurrencyCode currencyCode) {
    return MonthlyOrderSummaryWithCurrency(
        purchaseOrderCount: monthlyOrderSummary.purchaseOrderCount,
        purchaseOrderAmount: monthlyOrderSummary.purchaseOrderAmount,
        saleOrderCount: monthlyOrderSummary.saleOrderCount,
        saleOrderAmount: monthlyOrderSummary.saleOrderAmount,
        currencyCode: currencyCode);
  }
}
