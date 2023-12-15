import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inventory_frontend/view/routing/app.router.dart';
import 'package:inventory_frontend/view/sale.orders/line.item/selected.line.item.controller.dart';

class AddLineItemScreen extends ConsumerStatefulWidget {
  const AddLineItemScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddLineItemScreenState();
}

class _AddLineItemScreenState extends ConsumerState<AddLineItemScreen> {
  @override
  Widget build(BuildContext context) {
    final selectedLineItemOrNone = ref.watch(selectedLineItemProvider);
    final buttonText = selectedLineItemOrNone.fold(() => "Select Item", (r) => r.name);
    return Scaffold(
      appBar: AppBar(title: const Text("Add Line Item")),
      body: Column(
        children: [
          TextButton(
              onPressed: () {
                context.goNamed(AppRoute.itemsSelection.name);
              },
              child: Text(buttonText))
        ],
      ),
    );
  }
}
