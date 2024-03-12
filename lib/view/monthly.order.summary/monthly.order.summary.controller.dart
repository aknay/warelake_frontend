import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:warelake/data/monthly.order.summary/entities.dart';
import 'package:warelake/data/monthly.order.summary/monthly.order.summary.service.dart';

part 'monthly.order.summary.controller.g.dart';

@riverpod
class MonthlyOrderSummaryController extends _$MonthlyOrderSummaryController {
  @override
  Future<MonthlyOrderSummaryWithCurrency> build() async {
    final summaryOrError = await ref.watch(monthlyOrderSummaryServiceProvider).get();
    if (summaryOrError.isLeft()) {
      throw AssertionError("error while fetching items");
    }
    return summaryOrError.toIterable().first;
  }
}
