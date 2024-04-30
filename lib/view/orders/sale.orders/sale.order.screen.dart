import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:warelake/data/sale.order/sale.order.service.dart';
import 'package:warelake/domain/sale.order/entities.dart';
import 'package:warelake/view/common.widgets/async_value_widget.dart';
import 'package:warelake/view/common.widgets/currency.amount.text.dart';
import 'package:warelake/view/common.widgets/dialogs/yes.no.dialog.dart';
import 'package:warelake/view/common.widgets/widgets/note.text.dart';
import 'package:warelake/view/constants/app.sizes.dart';
import 'package:warelake/view/orders/common.widgets/line.item/read.only.line.item.list.view.dart';
import 'package:warelake/view/orders/sale.orders/sale.order.list.controller.dart';
import 'package:warelake/view/orders/sale.orders/widgets/sale.order.status.widget.dart';
import 'package:warelake/view/routing/app.router.dart';

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
    final popupMenuItems = so.status.fold(
        () => [
              const PopupMenuItem(
                value: SaleOrderAction.delete,
                child: Text('Delete'),
              ),
            ], (status) {
      switch (status) {
        case SaleOrderStatus.issued:
          return [
            const PopupMenuItem(
              value: SaleOrderAction.delivered,
              child: Text('Convert to Delivered'),
            ),
            const PopupMenuItem(
              value: SaleOrderAction.delete,
              child: Text('Delete'),
            ),
          ];
        case SaleOrderStatus.delivered:
          return [
            const PopupMenuItem(
              value: SaleOrderAction.delete,
              child: Text('Delete'),
            ),
          ];
      }
    });

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
                      if (context.mounted) {
                        final toDeleteOrNull = await showDialog<bool?>(
                          context: context,
                          builder: (BuildContext context) {
                            return const YesOrNoDialog(
                              actionWord: "Delete",
                              title: "Delete?",
                              content: "Are you sure you want to delete this sale order?",
                            );
                          },
                        );

                        if (toDeleteOrNull != null && toDeleteOrNull) {
                          final isSuccess = await ref.read(saleOrderListControllerProvider.notifier).delete(so);
                          if (isSuccess && context.mounted) {
                            context.goNamed(AppRoute.saleOrders.name);
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
                      CurrencyAmountText(amount: so.totalInDouble, currencyCode: so.currencyCodeEnum),
                    ],
                  ),
                  const Spacer(),
                  SaleOrderStausWidget(statusOrNone: so.status),
                ],
              ),
            ),
            gapH20,
            ReadOnlyLineItemListView(lineItems: so.lineItems),
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: NoteText(so.notes),
            )
          ],
        ));
  }
}
