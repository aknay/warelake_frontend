import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:warelake/view/orders/common.widgets/line.item/selected.line.item.controller.dart';
import 'package:warelake/view/routing/app.router.dart';

class LineItemSelectionWidget extends ConsumerWidget {
  const LineItemSelectionWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedLineItemOrNone = ref.watch(selectedItemVariationProvider);
    final buttonText = selectedLineItemOrNone.fold(() => "Select Item", (r) => r.name);

    return GestureDetector(
      onTap: () {
        final router = GoRouter.of(context);

        final path = router.routeInformationProvider.value.uri.path;

        if (path == router.namedLocation(AppRoute.addLineItemForPurchaseOrderFromDashboard.name)) {
          context.goNamed(
            AppRoute.itemsSelectionForPurchaseOrderFromDasboard.name,
          );
        } else if (path == router.namedLocation(AppRoute.addLineItemForPurchaseOrder.name)) {
          context.goNamed(
            AppRoute.itemsSelectionForPurchaseOrder.name,
          );
        } else if (path == router.namedLocation(AppRoute.addLineItemForSaleOrder.name)) {
          context.goNamed(
            AppRoute.itemsSelectionForSaleOrder.name,
          );
        } else if (path == router.namedLocation(AppRoute.addLineItemForSaleOrderFromDashboard.name)) {
          context.goNamed(
            AppRoute.itemsSelectionForSaleOrderFromDashboard.name,
          );
        }
      },
      child: TextFormField(
        enabled: false, // Make it non-editable
        decoration: InputDecoration(
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 12, top: 8),
            child: FaIcon(FontAwesomeIcons.cubesStacked, color: Colors.white),
          ),
          labelText: buttonText,
          labelStyle: Theme.of(context).textTheme.bodyLarge,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
