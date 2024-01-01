import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory_frontend/view/stock/stock.line.item.controller.dart';

class StockLineItemListView extends ConsumerWidget {
  const StockLineItemListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lineItems = ref.watch(stockLineItemControllerProvider);
    if (lineItems.isEmpty) {
      return const Center(child: Text("Empty. Please add"));
    }
    return ListView(
      children: lineItems
          .map((e) => ListTile(
                title: Text(e.itemVariation.name),
                trailing: SizedBox(
                    width: 80,
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      initialValue: '1',
                      onChanged: (value) {
                        optionOf(int.tryParse(value)).fold(
                            () => null,
                            (a) => ref
                                .read(stockLineItemControllerProvider.notifier)
                                .edit(itemVariationId: e.itemVariation.id!, value: a));
                      },
                    )),
                // subtitle: ,
                onTap: () {},
              ))
          .toList(),
    );
  }
}
