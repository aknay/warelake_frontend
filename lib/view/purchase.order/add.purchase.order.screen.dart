import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:warelake/domain/bill.account/entities.dart';
import 'package:warelake/domain/purchase.order/entities.dart';
import 'package:warelake/view/bill.account.selection/bill.account.selection.widget.dart';
import 'package:warelake/view/purchase.order/purchase.order.list.controller.dart';
import 'package:warelake/view/routing/app.router.dart';
import 'package:warelake/view/sale.orders/line.item/line.item.controller.dart';
import 'package:warelake/view/sale.orders/line.item/line.item.list.view.dart';
import 'package:warelake/view/utils/alert_dialogs.dart';

class AddPurchaseOrderScreen extends ConsumerStatefulWidget {
  const AddPurchaseOrderScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddSaleOrderScreenState();
}

class _AddSaleOrderScreenState extends ConsumerState<AddPurchaseOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  Option<BillAccount> _billAccountOrNone = const None();
  Option<String> _saleOrderNumberOrNone = const None();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("New Purchase Order"),
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
          labelText: 'Purchase Order # *',
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Enter a purchase order number first';
          }
          return null;
        },
        onSaved: (value) => _saleOrderNumberOrNone = value != null ? optionOf(value) : const None(),
      ),
      TextButton(
        onPressed: () async {
          context.goNamed(
            AppRoute.addLineItemForPurchaseOrder.name,
          );
        },
        child: const Text("Add Line Item"),
      ),
      BillAccountSelectionWidget(onValueChanged: (value) {
        log("value ${value.isSome()}");
        _billAccountOrNone = value;
      }),
      const Expanded(child: LineItemListView())
    ];
  }

  Future<void> _submit({required WidgetRef ref, required Option<BillAccount> billAccountOrNone}) async {
    if (_validateAndSaveForm()) {
      final lineItems = ref.read(lineItemControllerProvider);
      final subTotal =
          lineItems.map((e) => e.rate * e.quantity).fold(0, (previousValue, element) => previousValue + element);

      if (billAccountOrNone.isNone()) {
        showAlertDialog(
          context: context,
          title: "Empty",
          content: "Please select a bill Account first.",
          defaultActionText: "OK",
        );
        return;
      }

      if (lineItems.isEmpty) {
        showAlertDialog(
          context: context,
          title: "Empty",
          content: "Please add at least one line item",
          defaultActionText: "OK",
        );
        return;
      }

      final billAccount = billAccountOrNone.toIterable().first;

      final saleOrder = PurchaseOrder.create(
          date: DateTime.now(),
          currencyCode: billAccount.currencyCodeAsEnum,
          lineItems: lineItems,
          subTotal: subTotal,
          total: subTotal,
          accountId: billAccount.id!,
          purchaseOrderNumber: _saleOrderNumberOrNone.toIterable().first);

      final success = await ref.read(purchaseOrderListControllerProvider.notifier).createPurchaseOrder(saleOrder);

      if (success && context.mounted) {
        context.goNamed(AppRoute.purchaseOrders.name);
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
