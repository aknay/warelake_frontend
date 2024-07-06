import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warelake/domain/stock.transaction/entities.dart';
import 'package:warelake/view/item.variations/item.variation.image/item.variation.image.widget.dart';
import 'package:warelake/view/stock/stock.line.item.list.view/stock.line.item.controller.dart';

class StockLineItemListView extends ConsumerWidget {
  const StockLineItemListView({super.key, required this.onValueChanged});
  final void Function(List<StockLineItem> stockLinItemList) onValueChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<List<StockLineItem>>(
        stockLineItemControllerProvider, (_, state) => onValueChanged(state));

    final lineItems = ref.watch(stockLineItemControllerProvider);
    if (lineItems.isEmpty) {
      return const Center(child: Text("Please add at least one item"));
    }
    return ListView(
      children: lineItems
          .map((e) => ListTile(
                onTap: () {
                  showModalBottomSheet(
                      context: context,
                      constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.85),
                      builder: (BuildContext context) {
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              ListTile(
                                title: const Center(
                                  child: Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.redAccent),
                                  ),
                                ),
                                onTap: () {
                                  ref
                                      .read(stockLineItemControllerProvider
                                          .notifier)
                                      .remove(
                                          itemVariationId: e.itemVariation.id!);
                                  Navigator.pop(context);
                                },
                              ),
                              ListTile(
                                title: const Center(child: Text('Cancel')),
                                onTap: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                        );
                      });
                },
                leading: ItemVariationImageWidget(
                    itemId: e.itemVariation.itemId,
                    itemVariationId: e.itemVariation.id!,
                    isForTheList: true),
                title: Text(e.itemVariation.name),
                trailing: SizedBox(
                  width: 80,
                  child: TextFormField(
                    //TODO: disable key becuase it keeps refreshing while typing
                    //key need to be in random in order to initialValue be updated  ref: https://stackoverflow.com/a/63164782
                    // key: UniqueKey(),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),

                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'))
                    ],

                    initialValue: e.quantity.toString(),
                    onChanged: (value) {
                      optionOf(double.tryParse(value)).fold(
                          () => null,
                          (a) => ref
                              .read(stockLineItemControllerProvider.notifier)
                              .edit(
                                  itemVariationId: e.itemVariation.id!,
                                  value: a));
                    },
                  ),
                ),
              ))
          .toList(),
    );
  }
}
