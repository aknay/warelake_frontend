import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory_frontend/data/bill.account/bill.account.service.dart';
import 'package:inventory_frontend/data/monthly.summary/monthly.summary.chart.wrapper.dart';
import 'package:inventory_frontend/domain/bill.account/entities.dart';
import 'package:inventory_frontend/view/common.widgets/async_value_widget.dart';
import 'package:flutter/foundation.dart' as foundation;

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
            Row(
              children: [
                Column(
                  children: [
                    const Text("Total Amount"),
                    Text("${billAccount.currencyCodeAsEnum.name} ${billAccount.totalBalance}"),
                  ],
                ),
                // const Spacer(),
                Text(billAccount.status.toUpperCase())
              ],
            ),
                        SizedBox(height: 150, child: MonthlySummaryChartWrapper(billAccount: billAccount)),
            // Expanded(child: _getListView(so.lineItems))
          ],
        ));
  }
}
