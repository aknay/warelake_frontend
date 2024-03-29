import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warelake/domain/purchase.order/entities.dart';
import 'package:warelake/view/common.widgets/amount.text.dart';
import 'package:warelake/view/constants/app.sizes.dart';

class ReadOnlyLineItemListView extends ConsumerWidget {
  final List<LineItem> lineItems;
  const ReadOnlyLineItemListView({super.key, required this.lineItems});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (lineItems.isEmpty) {
      return const Expanded(
        child: Center(
          child: Text("No line item to display"),
        ),
      );
    }

    final middle = lineItems
        .map((e) => ListTile(
              title: Row(children: [Text(e.itemVariation.name), const Text(" x "), Text(e.quantity.toString())]),
              trailing: AmountText(e.totalAmount, style: Theme.of(context).textTheme.bodyLarge),
            ))
        .toList();

    const top = Row(children: [gapW16, Text('Items'), Spacer(), Text('Amount'), gapW20]);
    final total = lineItems.map((e) => e.totalAmount).fold(0.0, (previousValue, element) => previousValue + element);
    final bottom = Row(mainAxisAlignment: MainAxisAlignment.end, children: [
      const Text('Total:'),
      gapW8,
      AmountText(total, style: Theme.of(context).textTheme.bodyLarge),
      gapW20
    ]);
    return Column(children: [top, const Divider(), ...middle, const Divider(), bottom]);
  }
}
