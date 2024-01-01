import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inventory_frontend/domain/stock.transaction/entities.dart';
import 'package:inventory_frontend/view/main/drawer.dart';
import 'package:inventory_frontend/view/routing/app.router.dart';
import 'package:inventory_frontend/view/stock/stock.line.item.controller.dart';
import 'package:inventory_frontend/view/stock/stock.line.item.list.view.dart';
import 'package:inventory_frontend/view/stock/stock.transaction.list.controller.dart';

class StockAdjustScreen extends ConsumerStatefulWidget {
  const StockAdjustScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _StockAdjustScreenState();
}

class _StockAdjustScreenState extends ConsumerState<StockAdjustScreen> {
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: const DrawerWidget(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // final router = GoRouter.of(context);
            // final uri = router.routeInformationProvider.value.uri;
            // if (uri.path.contains('stock_out')) {
            //   context.goNamed(AppRoute.selectStockLineItemForStockOut.name);
            // } else if (uri.path.contains('stock_in')) {
            //   context.goNamed(AppRoute.selectStockLineItemForStockIn.name);
            // }

                    context.goNamed(AppRoute.selectStockLineItemForStockAdjust.name);
          },
          child: const Icon(Icons.add),
        ),
        appBar: AppBar(
          title: const Text("Stock Adjust"),
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
        stockMovement: StockMovement.stockAdjust,
      );

      final success = await ref.read(stockTransactionListControllerProvider.notifier).create(rawTx);
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
