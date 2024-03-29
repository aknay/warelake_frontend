import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:warelake/data/purchase.order/purchase.order.service.dart';
import 'package:warelake/domain/purchase.order/entities.dart';
import 'package:warelake/domain/purchase.order/valueobject.dart';
import 'package:warelake/view/common.widgets/async_value_widget.dart';
import 'package:warelake/view/common.widgets/currency.amount.text.dart';
import 'package:warelake/view/common.widgets/dialogs/yes.no.dialog.dart';
import 'package:warelake/view/constants/app.sizes.dart';
import 'package:warelake/view/orders/common.widgets/line.item/read.only.line.item.list.view.dart';
import 'package:warelake/view/orders/purchase.order/purchase.order.list.controller.dart';
import 'package:warelake/view/orders/purchase.order/widgets/purchase.order.status.widget.dart';
import 'package:warelake/view/routing/app.router.dart';

final purchaseOrderProvider = FutureProvider.family<PurchaseOrder, String>((ref, id) async {
  final saleOrderOrError = await ref.watch(purchaseOrderServiceProvider).getPurchaseOrder(purchaseOrderId: id);
  if (saleOrderOrError.isLeft()) {
    throw AssertionError("cannot item");
  }
  return saleOrderOrError.toIterable().first;
});

enum PurchaseOrderAction {
  delivered,
  delete,
}

class PurchaseOrderScreen extends ConsumerWidget {
  const PurchaseOrderScreen({super.key, required this.isToSelectItemVariation, required this.pruchaseOrderId});

  final String pruchaseOrderId;
  final bool isToSelectItemVariation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saleOrderAsync = ref.watch(purchaseOrderProvider(pruchaseOrderId));
    return ScaffoldAsyncValueWidget<PurchaseOrder>(
      value: saleOrderAsync,
      data: (job) => PageContents(po: job),
    );
  }
}

class PageContents extends ConsumerWidget {
  const PageContents({super.key, required this.po});
  final PurchaseOrder po;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final popupMenuItems = po.orderStatus == PurchaseOrderStatus.issued
        ? [
            const PopupMenuItem(
              value: PurchaseOrderAction.delivered,
              child: Text('Convert to Received'),
            ),
            const PopupMenuItem(
              value: PurchaseOrderAction.delete,
              child: Text('Delete'),
            ),
          ]
        : [
            const PopupMenuItem(
              value: PurchaseOrderAction.delete,
              child: Text('Delete'),
            ),
          ];

    return Scaffold(
        appBar: AppBar(
          title: Text(po.purchaseOrderNumber!),
          actions: [
            PopupMenuButton<PurchaseOrderAction>(
                onSelected: (PurchaseOrderAction value) async {
                  switch (value) {
                    case PurchaseOrderAction.delivered:
                      //TODO need to get a date from users
                      final now = DateTime.now();
                      final isSuccess =
                          await ref.read(purchaseOrderListControllerProvider.notifier).convertToReceived(po, now);
                      if (isSuccess) {
                        ref.invalidate(purchaseOrderProvider(po.id!));
                      }
                    case PurchaseOrderAction.delete:
                      if (context.mounted) {
                        final toDeleteOrNull = await showDialog<bool?>(
                          context: context,
                          builder: (BuildContext context) {
                            return const YesOrNoDialog(
                              actionWord: "Delete",
                              title: "Delete?",
                              content: "Are you sure you want to delete this purchase order?",
                            );
                          },
                        );

                        if (toDeleteOrNull != null && toDeleteOrNull) {
                          final isSuccess = await ref.read(purchaseOrderListControllerProvider.notifier).delete(po);
                          if (isSuccess && context.mounted) {
                            context.goNamed(AppRoute.purchaseOrders.name);
                          }
                        }
                      }
                  }
                },
                itemBuilder: (BuildContext context) => popupMenuItems)
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 12, right: 16),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Total Amount"),
                      CurrencyAmountText(amount: po.totalInDouble, currencyCode:  po.currencyCodeEnum),
                    ],
                  ),
                  const Spacer(),
                  PurchaseOrderStausWidget(po.orderStatus),
                ],
              ),
            ),
            gapH20,
            ReadOnlyLineItemListView(lineItems: po.lineItems),
          ],
        ));
  }
}
