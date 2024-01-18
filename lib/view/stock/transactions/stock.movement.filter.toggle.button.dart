import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory_frontend/domain/stock.transaction/entities.dart';

final _stockMovementFilteringStateProvider = StateProvider<StockMovement?>(
  (ref) => null,
);

class FilterStockToggleButton extends ConsumerStatefulWidget {
  const FilterStockToggleButton({super.key, required this.onChanged, required this.stockMovement});
  final void Function(StockMovement? stockMovement) onChanged;
  final StockMovement? stockMovement;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FilterStockToggleButtonState();
}

class _FilterStockToggleButtonState extends ConsumerState<FilterStockToggleButton> {
  late final List<bool> _isSelected = _getSelected(widget.stockMovement);

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
                  widget.onChanged(null);
                  ref.read(_stockMovementFilteringStateProvider.notifier).state = null;
                } else if (index == 1) {
                  widget.onChanged(StockMovement.stockIn);
                  ref.read(_stockMovementFilteringStateProvider.notifier).state = StockMovement.stockIn;
                } else if (index == 2) {
                  widget.onChanged(StockMovement.stockOut);
                  ref.read(_stockMovementFilteringStateProvider.notifier).state = StockMovement.stockOut;
                } else if (index == 3) {
                  widget.onChanged(StockMovement.stockAdjust);
                  ref.read(_stockMovementFilteringStateProvider.notifier).state = StockMovement.stockAdjust;
                }
              }
            });
          },
          children: children,
        ),
      );
    });
  }

  List<bool> _getSelected(StockMovement? stockMovement) {
    if (stockMovement == null) {
      return [true, false, false, false];
    }
    switch (stockMovement) {
      case StockMovement.stockIn:
        return [false, true, false, false];
      case StockMovement.stockOut:
        return [false, false, true, false];
      case StockMovement.stockAdjust:
        return [false, false, false, true];
    }
  }
}
