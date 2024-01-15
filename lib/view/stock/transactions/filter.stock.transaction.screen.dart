import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
            onPressed: () async {
              // await _submit(ref: ref);
            },
            // icon: const FaIcon(FontAwesomeIcons.c)),
          )
        ],
      ),
      body: const Column(
        children: [
          Text("Stock"),
          Row(
            children: [
              Expanded(child: StockTransactionToggleButton()),
            ],
          ),
        ],
      ),
    );
  }
}

final _toggleButtonStateProvider = StateProvider<List<bool>>(
  (ref) => [true, false, false, true],
);

class StockTransactionToggleButton extends ConsumerWidget {
  const StockTransactionToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // return LayoutBuilder(builder: (context, constraints) {
    final v = ref.watch(_toggleButtonStateProvider);
    log("the value here is $v");
    return ToggleButtons(
      renderBorder: false,
      // constraints: BoxConstraints.expand(width: constraints.maxWidth / 4),
      borderRadius: BorderRadius.circular(5),
      isSelected: v,
      selectedColor: Colors.green,
      onPressed: (index) {
        final value = ref.read(_toggleButtonStateProvider);

        for (int buttonIndex = 0; buttonIndex < value.length; buttonIndex++) {
          if (buttonIndex == index) {
            value[buttonIndex] = !value[buttonIndex];
          } else {
            value[buttonIndex] = false;
          }
        }

        // value[index] = !value[index];
        log("the value is $value");
        ref.read(_toggleButtonStateProvider.notifier).state = value;
      },
      children: const [
        Text('All'),
        Text('In'),
        Text('Out'),
        Text('Adjust'),
      ],
    );
    // });
  }
}
