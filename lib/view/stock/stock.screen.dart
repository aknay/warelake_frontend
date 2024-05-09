import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:warelake/domain/stock.transaction/entities.dart';
import 'package:warelake/view/common.widgets/widgets/date.selection.widget.dart';
import 'package:warelake/view/common.widgets/widgets/note.text.form.field.dart';
import 'package:warelake/view/constants/app.sizes.dart';
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
  var _dateTime = DateTime.now();
  Option<String> _note = const None();

  @override
  Widget build(BuildContext context) {
    final stockTransactionListAsync = ref.watch(stockTransactionListControllerProvider);

    if (stockTransactionListAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    String title;

    switch (widget.stockMovement) {
      case StockMovement.stockIn:
        title = "New Stock In";
        break;
      case StockMovement.stockOut:
        title = "New Stock Out";
        break;
      case StockMovement.stockAdjust:
        title = "New Stock Adjust";
    }

    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            final router = GoRouter.of(context);
            final path = router.routeInformationProvider.value.uri.path;

            switch (widget.stockMovement) {
              case StockMovement.stockIn:
                if (path == router.namedLocation(AppRoute.stockInFromTransactionList.name)) {
                  context.goNamed(AppRoute.selectStockLineItemForStockInFromTransactionList.name);
                } else {
                  context.goNamed(AppRoute.selectStockLineItemForStockIn.name);
                }
                break;

              case StockMovement.stockOut:
                if (path == router.namedLocation(AppRoute.stockOutFromTransactionList.name)) {
                  context.goNamed(AppRoute.selectStockLineItemForStockOutFromTransactionList.name);
                } else {
                  context.goNamed(AppRoute.selectStockLineItemForStockOutFromDashboard.name);
                }
                break;
              case StockMovement.stockAdjust:
                if (path == router.namedLocation(AppRoute.stockAdjustFromTransactionList.name)) {
                  context.goNamed(AppRoute.selectStockLineItemForStockAdjustFromTransactionList.name);
                } else {
                  context.goNamed(AppRoute.selectStockLineItemForStockAdjustFromDashboard.name);
                }
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
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: DateSelectionWidget(onValueChanged: (value) {
          _dateTime = value;
        }),
      ),
      Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8),
        child: NoteTextFormField(onChanged: (value) {
          _note = Some(value);
        }),
      ),
      gapH12,
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
          date: _dateTime, lineItems: stockLineItemList, stockMovement: widget.stockMovement, notes: _note);

      final success = await ref.read(stockTransactionListControllerProvider.notifier).create(rawTx);

      if (success && mounted) {
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
