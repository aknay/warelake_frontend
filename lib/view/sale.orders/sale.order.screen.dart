import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warelake/data/sale.order/sale.order.service.dart';
import 'package:warelake/domain/purchase.order/entities.dart';
import 'package:warelake/domain/sale.order/entities.dart';
import 'package:warelake/view/common.widgets/async_value_widget.dart';
import 'package:warelake/view/sale.orders/sale.order.list.controller.dart';

final saleOrderProvider = FutureProvider.family<SaleOrder, String>((ref, id) async {
  final saleOrderOrError = await ref.watch(saleOrderServiceProvider).getSaleOrder(saleOrderId: id);
  if (saleOrderOrError.isLeft()) {
    throw AssertionError("cannot item");
  }
  return saleOrderOrError.toIterable().first;
});

enum SaleOrderAction {
  delivered,
  delete,
}

class SaleOrderScreen extends ConsumerWidget {
  const SaleOrderScreen({super.key, required this.isToSelectItemVariation, required this.saleOrderId});

  final String saleOrderId;
  final bool isToSelectItemVariation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saleOrderAsync = ref.watch(saleOrderProvider(saleOrderId));
    return ScaffoldAsyncValueWidget<SaleOrder>(
      value: saleOrderAsync,
      data: (job) => PageContents(so: job),
    );
  }
}

class PageContents extends ConsumerWidget {
  const PageContents({super.key, required this.so});
  final SaleOrder so;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final popupMenuItems = so.saleOrderStatus == SaleOrderStatus.processing
        ? [
            const PopupMenuItem(
              value: SaleOrderAction.delivered,
              child: Text('Convert to Delivered'),
            ),
            const PopupMenuItem(
              value: SaleOrderAction.delete,
              child: Text('Delete'),
            ),
          ]
        : [
            const PopupMenuItem(
              value: SaleOrderAction.delete,
              child: Text('Delete'),
            ),
          ];

    return Scaffold(
        appBar: AppBar(
          title: Text(so.saleOrderNumber!),
          actions: [
            PopupMenuButton<SaleOrderAction>(
                onSelected: (SaleOrderAction value) async {
                  switch (value) {
                    case SaleOrderAction.delivered:
                      final isSuccess = await ref.read(saleOrderListControllerProvider.notifier).convertToDelivered(so);
                      if (isSuccess) {
                        ref.invalidate(saleOrderProvider(so.id!));
                      }
                    case SaleOrderAction.delete:
                    // TODO: Handle this case.
                  }
                },
                itemBuilder: (BuildContext context) => popupMenuItems)
          ],
        ),
        body: Column(
          children: [
            Row(
              children: [
                Column(
                  children: [
                    const Text("Total Amount"),
                    Text("${so.currencyCodeEnum.name} ${so.totalInDouble}"),
                  ],
                ),
                const Spacer(),
                Text(so.status!.toUpperCase())
              ],
            ),
            Expanded(child: _getListView(so.lineItems))
          ],
        ));
  }

  ListView _getListView(List<LineItem> lineItems) {
    return ListView(
      children: lineItems
          .map((e) => ListTile(
                title: Text(e.itemVariation.name),
                subtitle:
                    Row(children: [Text(e.quantity.toString()), const Text(" X "), Text(e.rateInDouble.toString())]),
                // onTap: () {},
              ))
          .toList(),
    );
  }
}
