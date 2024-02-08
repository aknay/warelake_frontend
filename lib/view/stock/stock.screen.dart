import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:warelake/domain/stock.transaction/entities.dart';
import 'package:warelake/view/main/drawer/drawer.dart';
import 'package:warelake/view/routing/app.router.dart';
import 'package:warelake/view/stock/stock.line.item.list.view/stock.line.item.list.view.dart';
import 'package:warelake/view/stock/stock.transaction.list.controller.dart';
import 'package:warelake/view/utils/alert_dialogs.dart';

final _stockLineItemProvider = StateProvider<List<StockLineItem>>((ref) => const []);

class StockScreen extends ConsumerStatefulWidget {
  const StockScreen({super.key, required this.stockMovement});

  final StockMovement stockMovement;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _StockInScreenState();
}

class _StockInScreenState extends ConsumerState<StockScreen> {
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final stockTransactionListAsync = ref.watch(stockTransactionListControllerProvider);

    if (stockTransactionListAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    String title;

    switch (widget.stockMovement) {
      case StockMovement.stockIn:
        title = "Stock In";
      case StockMovement.stockOut:
        title = "Stock Out";
      case StockMovement.stockAdjust:
        title = "Stock Adjust";
    }

    return Scaffold(
        drawer: const DrawerWidget(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            switch (widget.stockMovement) {
              case StockMovement.stockIn:
                context.goNamed(AppRoute.selectStockLineItemForStockIn.name);
              case StockMovement.stockOut:
                context.goNamed(AppRoute.selectStockLineItemForStockOut.name);
              case StockMovement.stockAdjust:
                context.goNamed(AppRoute.selectStockLineItemForStockAdjust.name);
            }
          },
          child: const Icon(Icons.add),
        ),
        appBar: AppBar(
          title: Text(title),
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
    return [
      Expanded(child: StockLineItemListView(
        onValueChanged: (stockLinItemList) {
          ref.read(_stockLineItemProvider.notifier).state = stockLinItemList;
        },
      ))
    ];
  }

  Future<void> _submit({required WidgetRef ref}) async {
    if (_validateAndSaveForm()) {
      final stockLineItemList = ref.read(_stockLineItemProvider);
      if (stockLineItemList.isEmpty) {
        showAlertDialog(
            context: context, title: "Empty", content: "Line item cannot be empty.", defaultActionText: "OK");
        return;
      }

      final rawTx = StockTransaction.create(
        date: DateTime.now(),
        lineItems: stockLineItemList,
        stockMovement: widget.stockMovement,
      );

      final success = await ref.read(stockTransactionListControllerProvider.notifier).create(rawTx);

      if (success && context.mounted) {
        context.goNamed(AppRoute.stockTransactions.name);
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
