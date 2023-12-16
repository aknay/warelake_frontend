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
  Option<BillAccount> _billAccountOrNone = const None();

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
      body: Column(
        children: [
          TextButton(
            onPressed: () async {
              context.goNamed(
                AppRoute.addLineItem.name,
              );
            },
            child: const Text("Add Line Item"),
          ),
          BillAccountSelectionWidget(onValueChanged: (value) {
            log("value ${value.isSome()}");
            _billAccountOrNone = value;
          }),
          const Expanded(child: LineItemListView())
        ],
      ),
    );
  }

  Future<void> _submit({required WidgetRef ref, required Option<BillAccount> billAccountOrNone}) async {
    final lineItems = ref.read(lineItemControllerProvider);
    final subTotal = lineItems
        .map((e) => e.rate * e.quantity)
        .fold(0, (previousValue, element) => previousValue + element);

    final billAccount = billAccountOrNone.toIterable().first;

    final saleOrder = SaleOrder.create(
        date: DateTime.now(),
        currencyCode: billAccount.currencyCodeAsEnum,
        lineItems: lineItems,
        subTotal: subTotal,
        total: subTotal,
        accountId: billAccount.id!);

    final success = await ref.read(saleOrderListControllerProvider.notifier).createSaleOrder(saleOrder);

    if (success && context.mounted) {
      context.goNamed(AppRoute.saleOrders.name);
    }
  }
}
