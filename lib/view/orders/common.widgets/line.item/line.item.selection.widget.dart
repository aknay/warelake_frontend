import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:warelake/view/item.variations/item.variations.screen/item.variations.list.view.dart';
import 'package:warelake/view/orders/common.widgets/line.item/selected.line.item.controller.dart';
import 'package:warelake/view/stock/stock.item.variation.selection.dart';

class LineItemSelectionWidget extends ConsumerWidget {
  const LineItemSelectionWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedLineItemOrNone = ref.watch(selectedItemVariationProvider);
    final buttonText = selectedLineItemOrNone.fold(() => "Select Item", (r) => r.name);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const StockItemVariationSelectionScreen(ItemVariationSelection.forOrder)),
        );
      },
      child: TextFormField(
        enabled: false, // Make it non-editable
        decoration: InputDecoration(
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 12, top: 8),
            child: FaIcon(FontAwesomeIcons.cubesStacked, color: Colors.white),
          ),
          labelText: buttonText,
          labelStyle: Theme.of(context).textTheme.bodyLarge,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
