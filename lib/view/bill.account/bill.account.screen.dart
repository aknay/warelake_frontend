import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warelake/data/bill.account/bill.account.service.dart';
import 'package:warelake/data/monthly.summary/monthly.summary.chart.wrapper.dart';
import 'package:warelake/domain/bill.account/entities.dart';
import 'package:warelake/view/common.widgets/amount.text.dart';
import 'package:warelake/view/common.widgets/async_value_widget.dart';

final billAccountProvider = FutureProvider.family<BillAccount, String>((ref, id) async {
  if (foundation.kDebugMode) {
    await Future.delayed(const Duration(seconds: 1));
  }
  final billAccountIdOrError = await ref.watch(billAccountServiceProvider).get(billAccountId: id);
  if (billAccountIdOrError.isLeft()) {
    throw AssertionError("cannot item");
  }
  return billAccountIdOrError.toIterable().first;
});

class BillAccountScreen extends ConsumerWidget {
  const BillAccountScreen({super.key, required this.billAccountId});
  final String billAccountId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final billAccountAsync = ref.watch(billAccountProvider(billAccountId));

    return ScaffoldAsyncValueWidget<BillAccount>(
      value: billAccountAsync,
      data: (job) => PageContents(billAccount: job),
    );
  }
}

class PageContents extends ConsumerWidget {
  const PageContents({super.key, required this.billAccount});
  final BillAccount billAccount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Account Detail"),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 16),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Total Amount"),
                      AmountText(billAccount.totalBalance)
                    ],
                  ),
                  Text(billAccount.status.toUpperCase())
                ],
              ),
            ),
            SizedBox(height: 150, child: MonthlySummaryChartWrapper(billAccount: billAccount)),
            // Expanded(child: _getListView(so.lineItems))
          ],
        ));
  }
}
