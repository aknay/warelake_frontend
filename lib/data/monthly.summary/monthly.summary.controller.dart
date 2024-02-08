
import 'package:warelake/data/currency.code/valueobject.dart';
import 'package:warelake/data/monthly.summary/monthly.summary.service.dart';
import 'package:warelake/domain/monthly.summary/entities.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'monthly.summary.controller.g.dart';

@riverpod
class MonthlySummaryController extends _$MonthlySummaryController {
  @override
  Future<List<MonthlySummary>> build({required BillAccountId billAccountId}) async {
    return _fetchMonthlySummaryList();
  }

  Future<List<MonthlySummary>> _fetchMonthlySummaryList() async {
    final summaryListOrError = await ref.read(monthlySummaryServiceProvider).get(billAccountId: billAccountId);
    return summaryListOrError.fold((l) => [], (r) => r);
  }
}
