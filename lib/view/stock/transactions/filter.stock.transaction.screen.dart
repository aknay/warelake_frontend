import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum StockFiltering { all, stockIn, stockOut, stockAdjust }

final stockFilteringStateProvider = StateProvider<StockFiltering>(
  (ref) => StockFiltering.all,
);

class FilterStockTransactionScreen extends ConsumerWidget {
  const FilterStockTransactionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      // drawer: const DrawerWidget(),
      appBar: AppBar(
        title: const Text("Filter"),
        actions: [
          TextButton(
            child: const Text('Clear'),
            onPressed: () async {},
          )
        ],
      ),
      body: const Column(
        children: [
          Text("Stock"),
          Row(
            children: [
              // we need to use expanded for using LayoutBuilder
              Expanded(child: FilterStockToggleButton()),
            ],
          ),
        ],
      ),
    );
  }
}

class FilterStockToggleButton extends ConsumerStatefulWidget {
  const FilterStockToggleButton({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FilterStockToggleButtonState();
}

class _FilterStockToggleButtonState extends ConsumerState<FilterStockToggleButton> {
  final List<bool> _isSelected = [true, false, false, false];

  @override
  Widget build(BuildContext context) {
    //ref: https://github.com/invoiceninja/admin-portal/blob/54777d31bd42eab571e5b8c21100299a65500a41/lib/ui/app/forms/app_toggle_buttons.dart#L23
    return LayoutBuilder(builder: (context, constraints) {
      double toggleWidth = (constraints.maxWidth - 26) / 4;
      final labels = ["All", "In", "Out", "Adjust"];

      final children = labels
          .map((label) => SizedBox(
                width: toggleWidth,
                child: Center(
                    child: Text(
                  label[0].toUpperCase() + label.substring(1),
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                )),
              ))
          .toList();

      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: ToggleButtons(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          isSelected: _isSelected,
          onPressed: (index) {
            setState(() {
              for (int i = 0; i < _isSelected.length; i++) {
                _isSelected[i] = i == index;
                if (index == 0) {
                  ref.read(stockFilteringStateProvider.notifier).state = StockFiltering.all;
                } else if (index == 1) {
                  ref.read(stockFilteringStateProvider.notifier).state = StockFiltering.stockIn;
                } else if (index == 2) {
                  ref.read(stockFilteringStateProvider.notifier).state = StockFiltering.stockOut;
                } else if (index == 3) {
                  ref.read(stockFilteringStateProvider.notifier).state = StockFiltering.stockAdjust;
                }
              }
            });
          },
          children: children,
        ),
      );
    });
  }
}
