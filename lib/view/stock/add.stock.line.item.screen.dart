import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:warelake/domain/purchase.order/entities.dart';
import 'package:warelake/view/routing/app.router.dart';
import 'package:warelake/view/orders/common.widgets/line.item/line.item.controller.dart';
import 'package:warelake/view/orders/common.widgets/line.item/selected.line.item.controller.dart';

class AddStockLineItemScreen extends ConsumerStatefulWidget {
  const AddStockLineItemScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddLineItemScreenState();
}

class _AddLineItemScreenState extends ConsumerState<AddStockLineItemScreen> {
  final _formKey = GlobalKey<FormState>();
  Option<int> quantity = const Some(0);
  Option<double> rate = const Some(0.0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Add Stock Line Item"),
          actions: [
            IconButton(
                onPressed: () async {
                  await _submit(ref: ref);
                },
                icon: const Icon(Icons.check)),
          ],
        ),
        body: _buildForm(ref: ref));
  }

  Widget _buildForm({required WidgetRef ref}) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _buildFormChildren(ref: ref),
      ),
    );
  }

  List<Widget> _buildFormChildren({required WidgetRef ref}) {
    final selectedLineItemOrNone = ref.watch(selectedItemVariationProvider);
    final buttonText = selectedLineItemOrNone.fold(() => "Select Item", (r) => r.name);
    return [
      TextButton(
          onPressed: () {
            final router = GoRouter.of(context);
            final uri = router.routeInformationProvider.value.uri;
            if (uri.path.contains('purchase_order')) {
              context.goNamed(AppRoute.itemsSelectionForPurchaseOrder.name);
            } else {
              context.goNamed(AppRoute.itemsSelectionForSaleOrder.name);
            }
          },
          child: Text(buttonText)),
      Row(
        children: [
          Expanded(
            child: TextFormField(
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: const InputDecoration(
                labelText: 'Quantity *',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Enter a valid quantity';
                }
                return null;
              },
              onSaved: (value) => quantity = value != null ? optionOf(int.tryParse(value)) : const Some(0),
            ),
          ),
          Expanded(
            child: TextFormField(
              decoration: const InputDecoration(
                labelText: 'Rate *',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a rate';
                }
                return null;
              },
              onSaved: (value) {
                rate = value != null ? optionOf(double.tryParse(value)) : const Some(0.0);
                log("The rate gerer is ${rate.toIterable().first}");
              },
              keyboardType: const TextInputType.numberWithOptions(
                signed: false,
                decimal: false,
              ),
            ),
          )
        ],
      )
    ];
  }

  Future<void> _submit({required WidgetRef ref}) async {
    if (_validateAndSaveForm()) {
      final selectedItemVariationOrNone = ref.watch(selectedItemVariationProvider);
      final itemVariation = selectedItemVariationOrNone.toIterable().first;
      log("The rate is ${rate.toIterable().first}");
      final lineItem = LineItem.create(
          itemVariation: itemVariation,
          rate: rate.toIterable().first,
          quantity: quantity.toIterable().first,
          unit: "some unit");
      ref.read(lineItemControllerProvider.notifier).add(lineItem);

      context.pop();
    }
  }

  bool _validateAndSaveForm() {
    final form = _formKey.currentState!;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }
}
