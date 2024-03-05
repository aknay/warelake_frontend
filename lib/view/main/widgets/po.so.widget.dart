import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:warelake/view/purchase.order/purchase.order.list.controller.dart';
import 'package:warelake/view/routing/app.router.dart';
import 'package:warelake/view/sale.orders/sale.order.list.controller.dart';

class PoSoWidget extends ConsumerWidget {
  const PoSoWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // we need to listen this because we are adding po from the dashboard and we need to the purchaseOrderListControllerProvider to add
    ref.watch(purchaseOrderListControllerProvider);
    ref.watch(saleOrderListControllerProvider);
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).highlightColor, borderRadius: const BorderRadius.all(Radius.circular(8))),
      child: Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Text('Purchase/Sale', style: Theme.of(context).textTheme.titleLarge),
            ),
            ListTile(
              leading: const FaIcon(FontAwesomeIcons.bagShopping),
              title: const Text('Purchase Order'),
              trailing: const FaIcon(FontAwesomeIcons.angleRight),
              onTap: () {
                context.goNamed(AppRoute.addPurchaseOrderFromDashboard.name);
              },
            ),
            ListTile(
              leading: const FaIcon(FontAwesomeIcons.fileInvoiceDollar),
              title: const Text('Sale Order'),
              trailing: const FaIcon(FontAwesomeIcons.angleRight),
              onTap: () {
                context.goNamed(AppRoute.addSaleOrderFromDashboard.name);
              },
            ),
          ],
        ),
      ),
    );
  }
}
