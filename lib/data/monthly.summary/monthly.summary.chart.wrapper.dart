
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory_frontend/data/monthly.summary/monthly.summary.chart.dart';
import 'package:inventory_frontend/data/monthly.summary/monthly.summary.controller.dart';
import 'package:inventory_frontend/domain/bill.account/entities.dart';

class MonthlySummaryChartWrapper extends ConsumerWidget {
  final BillAccount billAccount;
  const MonthlySummaryChartWrapper({super.key, required this.billAccount});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncMonthlySummaryValue = ref.watch(monthlySummaryControllerProvider(billAccountId: billAccount.id!));
    return asyncMonthlySummaryValue.when(
        data: (data) {
          return MonthlySummaryChart(monthlySummaryList: data, currencyCode: billAccount.currencyCodeAsEnum);
        },
        error: (Object error, StackTrace stackTrace) => const Center(child: Text("Having error")),
        loading: () => const Center(child: CircularProgressIndicator()));
  }
}
