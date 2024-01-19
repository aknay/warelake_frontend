import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inventory_frontend/domain/bill.account/entities.dart';
import 'package:inventory_frontend/domain/sale.order/entities.dart';
import 'package:inventory_frontend/view/bill.account.selection/bill.account.selection.widget.dart';
import 'package:inventory_frontend/view/routing/app.router.dart';
import 'package:inventory_frontend/view/sale.orders/line.item/line.item.controller.dart';
import 'package:inventory_frontend/view/sale.orders/line.item/line.item.list.view.dart';
import 'package:inventory_frontend/view/sale.orders/sale.order.list.controller.dart';

class AddSaleOrderScreen extends ConsumerStatefulWidget {
  const AddSaleOrderScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddSaleOrderScreenState();
}

class _AddSaleOrderScreenState extends ConsumerState<AddSaleOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  Option<BillAccount> _billAccountOrNone = const None();
  Option<String> _saleOrderNumberOrNone = const None();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("New Sale Order"),
          actions: [
            IconButton(
                onPressed: () async {
                  await _submit(ref: ref, billAccountOrNone: _billAccountOrNone);
                },
                icon: const Icon(Icons.check)),
          ],
        ),
        body: _buildForm(ref: ref));
  }

  Widget _buildForm({required WidgetRef ref}) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _buildFormChildren(ref: ref),
      ),
    );
  }

  List<Widget> _buildFormChildren({required WidgetRef ref}) {
    return [
      TextFormField(
        decoration: const InputDecoration(
          labelText: 'Sale Order # *',
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Enter a valid quantity';
          }
          return null;
        },
        onSaved: (value) => _saleOrderNumberOrNone = value != null ? optionOf(value) : const None(),
      ),
     
      BillAccountSelectionWidget(onValueChanged: (value) {
        log("value ${value.isSome()}");
        _billAccountOrNone = value;
      }),
       TextButton(
          onPressed: () async {
            final router = GoRouter.of(context);
            final uri = router.routeInformationProvider.value.uri;

            if (uri.path.contains('purchase_order')) {
              context.goNamed(
                AppRoute.addLineItemForPurchaseOrder.name,
              );
            } else {
              context.goNamed(
                AppRoute.addLineItemForSaleOrder.name,
              );
            }
          },
          child: const Text("Add Line Item")),
      const Expanded(child: LineItemListView())
    ];
  }

  Future<void> _submit({required WidgetRef ref, required Option<BillAccount> billAccountOrNone}) async {
    if (_validateAndSaveForm()) {
      final lineItems = ref.read(lineItemControllerProvider);
      final subTotal =
          lineItems.map((e) => e.rate * e.quantity).fold(0, (previousValue, element) => previousValue + element);

      final billAccount = billAccountOrNone.toIterable().first;

      final saleOrder = SaleOrder.create(
          date: DateTime.now(),
          currencyCode: billAccount.currencyCodeAsEnum,
          lineItems: lineItems,
          subTotal: subTotal,
          total: subTotal,
          accountId: billAccount.id!,
          saleOrderNumber: _saleOrderNumberOrNone.toIterable().first);

      final success = await ref.read(saleOrderListControllerProvider.notifier).createSaleOrder(saleOrder);

      if (success && context.mounted) {
        context.goNamed(AppRoute.saleOrders.name);
      }
    }
  }

  bool _validateAndSaveForm() {
    final form = _formKey.currentState!;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }
}
