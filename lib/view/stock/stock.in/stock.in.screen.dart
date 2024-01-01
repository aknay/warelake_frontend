import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inventory_frontend/domain/stock.transaction/entities.dart';
import 'package:inventory_frontend/view/main/drawer.dart';
import 'package:inventory_frontend/view/routing/app.router.dart';
import 'package:inventory_frontend/view/stock/stock.line.item.controller.dart';
import 'package:inventory_frontend/view/stock/stock.line.item.list.view.dart';
import 'package:inventory_frontend/view/stock/stock.transaction.list.controller.dart';

class StockInScreen extends ConsumerStatefulWidget {
  const StockInScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _StockInScreenState();
}

class _StockInScreenState extends ConsumerState<StockInScreen> {
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: const DrawerWidget(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            context.goNamed(AppRoute.selectStockLineItemForStockIn.name);
          },
          child: const Icon(Icons.add),
        ),
        appBar: AppBar(
          title: const Text("Stock In"),
          actions: [
            IconButton(
                onPressed: () async {
                  await _submit(ref: ref);
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
    return [const Expanded(child: StockLineItemListView())];
  }

  Future<void> _submit({required WidgetRef ref}) async {
    if (_validateAndSaveForm()) {
      final stockLineItemList = ref.read(stockLineItemControllerProvider);

      final rawTx = StockTransaction.create(
        date: DateTime.now(),
        lineItems: stockLineItemList,
        stockMovement: StockMovement.stockIn,
      );

      final success = await ref.read(stockTransactionListControllerProvider.notifier).create(rawTx);

      // final lineItems = ref.read(lineItemControllerProvider);
      // final subTotal =
      //     lineItems.map((e) => e.rate * e.quantity).fold(0, (previousValue, element) => previousValue + element);

      // final billAccount = billAccountOrNone.toIterable().first;

      // final saleOrder = SaleOrder.create(
      //     date: DateTime.now(),
      //     currencyCode: billAccount.currencyCodeAsEnum,
      //     lineItems: lineItems,
      //     subTotal: subTotal,
      //     total: subTotal,
      //     accountId: billAccount.id!,
      //     saleOrderNumber: _saleOrderNumberOrNone.toIterable().first);

      // final success = await ref.read(saleOrderListControllerProvider.notifier).createSaleOrder(saleOrder);

      // if (success && context.mounted) {
      //   context.goNamed(AppRoute.saleOrders.name);
      // }
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
