import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory_frontend/domain/stock.transaction/entities.dart';
import 'package:inventory_frontend/view/constants/app.sizes.dart';
import 'package:inventory_frontend/view/stock/transactions/entities.dart';
import 'package:inventory_frontend/view/stock/transactions/stock.filter.provider.dart';
import 'package:inventory_frontend/view/stock/transactions/stock.movement.filter.toggle.button.dart';

final _stockMovementProvider = StateProvider<StockMovement?>(
  (ref) => null,
);

class FilterStockTransactionScreen extends ConsumerWidget {
  const FilterStockTransactionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Filter"),
        actions: [
          TextButton(
            child: const Text('Clear'),
            onPressed: () async {},
          )
        ],
      ),
      body: Column(
        children: [
          const Text("Stock"),
          Row(
            children: [
              // we need to use expanded for using LayoutBuilder
              Expanded(
                child: FilterStockToggleButton(
                  onChanged: (value) {
                    ref.read(_stockMovementProvider.notifier).state = value;
                  },
                  stockMovement: ref.watch(stockTransctionFilterProvider).stockMovement,
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                      onPressed: () {
                        ref.read(stockTransctionFilterProvider.notifier).state =
                            StockTransactionFilter(stockMovement: ref.read(_stockMovementProvider));
                        Navigator.pop(context);
                      },
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3.0),
                        )),
                      ),
                      child: const Text('Apply')),
                ),
              ),
            ],
          ),
          gapH8
        ],
      ),
    );
  }
}
