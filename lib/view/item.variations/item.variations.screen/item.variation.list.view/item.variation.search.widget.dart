import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warelake/view/barcode/barcode.scanner.value.controller.dart';
import 'package:warelake/view/barcode/barcode.scanner.widget.dart';
import 'package:warelake/view/constants/app.sizes.dart';

final searchItemVariationByBarcodeProvider = StateProvider.autoDispose<Option<String>>((ref) => const None());

class ItemVariationSearchWidget extends ConsumerStatefulWidget {
  const ItemVariationSearchWidget({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ItemVariationSearchWidgetState();
}

class _ItemVariationSearchWidgetState extends ConsumerState<ItemVariationSearchWidget> {
  late Key? anotherKey = UniqueKey();

  @override
  Widget build(BuildContext context) {
    ref.listen(barcodeScannerValueControllerProvider, (previous, next) {
      if (next.isSome()) {
        // once we get a barcode from the scanner we set it in searchItemVariationByBarcodeProvider and
        // set anotherKey to unique key so that TextFormField will be updated with the barcode
        ref.read(searchItemVariationByBarcodeProvider.notifier).state = next;
        anotherKey = UniqueKey();
      }
    });

    return Row(
      children: [
        gapW16,
        Expanded(
          child: TextFormField(
            key: anotherKey,
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
              hintText: "Search items by barcode",
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
