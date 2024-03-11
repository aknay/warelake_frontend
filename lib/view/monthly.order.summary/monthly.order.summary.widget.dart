import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warelake/view/constants/app.sizes.dart';
import 'package:warelake/view/monthly.order.summary/monthly.order.summary.controller.dart';

class MonthlyOrderSummaryWdiget extends ConsumerWidget {
  const MonthlyOrderSummaryWdiget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(monthlyOrderSummaryControllerProvider);
    return summary.when(
        data: (data) {
          return Container(
            decoration: BoxDecoration(
                color: Theme.of(context).highlightColor, borderRadius: const BorderRadius.all(Radius.circular(8))),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(children: [
                      Text('Purchase Order', style: Theme.of(context).textTheme.labelMedium),
                      gapH12,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              Row(
                                children: [
                                  Text('\$ ', style: Theme.of(context).textTheme.labelSmall),
                                  Text("${data.purchaseOrderAmount}", style: Theme.of(context).textTheme.headlineSmall)
                                ],
                              ),
                              Text('Amount', style: Theme.of(context).textTheme.labelSmall)
                            ],
                          ),
                          Column(
                            children: [
                              Text("${data.purchaseOrderCount}", style: Theme.of(context).textTheme.headlineSmall),
                              Text('Count', style: Theme.of(context).textTheme.labelSmall),
                            ],
                          )
                        ],
                      )
                    ]),
                  ),
                  const VerticalDivider(color: Colors.red, thickness: 2),
                  Expanded(
                    child: Column(children: [
                      const Text('Sale Order'),
                      gapH12,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              Row(
                                children: [
                                  Text('\$ ', style: Theme.of(context).textTheme.labelSmall),
                                  Text("${data.saleOrderAmount}", style: Theme.of(context).textTheme.headlineSmall)
                                ],
                              ),
                              Text('Amount', style: Theme.of(context).textTheme.labelSmall)
                            ],
                          ),
                          Column(
                            children: [
                              Text("${data.saleOrderCount}", style: Theme.of(context).textTheme.headlineSmall),
                              Text('Count', style: Theme.of(context).textTheme.labelSmall)
                            ],
                          )
                        ],
                      )
                    ]),
                  ),
                ],
              ),
            ),
          );
        },
        error: (Object error, StackTrace stackTrace) {
          return const Text("error");
        },
        loading: () => const Center(
              child: CircularProgressIndicator(),
            ));
  }
}
