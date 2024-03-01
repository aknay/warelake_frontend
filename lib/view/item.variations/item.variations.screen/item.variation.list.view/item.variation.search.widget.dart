import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warelake/view/barcode/barcode.scanner.value.controller.dart';
import 'package:warelake/view/barcode/barcode.scanner.widget.dart';

final searchItemVariationByBarcodeProvider = StateProvider.autoDispose<Option<String>>(
  (ref) {
    return ref.watch(barcodeScannerValueControllerProvider);
  },
);

class ItemVariationSearchWidget extends ConsumerWidget {
  const ItemVariationSearchWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            key: UniqueKey(),
            initialValue: ref.watch(searchItemVariationByBarcodeProvider).toNullable(),
            onChanged: (value) async {
              if (value.isEmpty) {
                ref.read(searchItemVariationByBarcodeProvider.notifier).state = const None();
              } else if (value.length > 2) {
                ref.read(searchItemVariationByBarcodeProvider.notifier).state = Some(value);
              }
            },
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search, color: Colors.white),
              hintText: "Search item by barcode",
              labelStyle: Theme.of(context).textTheme.bodyLarge,
              border: const OutlineInputBorder(),
            ),
          ),
        ),
        const BarcodeScannerWidget()
      ],
    );
  }
}
