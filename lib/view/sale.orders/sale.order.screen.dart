import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory_frontend/data/sale.order/sale.order.service.dart';
import 'package:inventory_frontend/domain/purchase.order/entities.dart';
import 'package:inventory_frontend/domain/sale.order/entities.dart';
import 'package:inventory_frontend/view/common.widgets/async_value_widget.dart';

final saleOrderProvider = FutureProvider.family<SaleOrder, String>((ref, id) async {
  final itemOrError = await ref.watch(saleOrderServiceProvider).getSaleOrder(saleOrderId: id);
  if (itemOrError.isLeft()) {
    throw AssertionError("cannot item");
  }
  return itemOrError.toIterable().first;
});

class SaleOrderScreen extends ConsumerWidget {
  const SaleOrderScreen({super.key, required this.isToSelectItemVariation, required this.saleOrderId});

  final String saleOrderId;
  final bool isToSelectItemVariation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobAsync = ref.watch(saleOrderProvider(saleOrderId));
    return ScaffoldAsyncValueWidget<SaleOrder>(
      value: jobAsync,
      data: (job) => PageContents(so: job, isToSelectItemVariation: isToSelectItemVariation),
    );
  }
}

class PageContents extends StatelessWidget {
  const PageContents({super.key, required this.isToSelectItemVariation, required this.so});
  final SaleOrder so;
  final bool isToSelectItemVariation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(so.saleOrderNumber!)),
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
