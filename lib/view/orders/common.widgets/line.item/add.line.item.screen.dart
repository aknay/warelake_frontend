import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:warelake/domain/purchase.order/entities.dart';
import 'package:warelake/view/constants/app.sizes.dart';
import 'package:warelake/view/orders/common.widgets/line.item/line.item.controller.dart';
import 'package:warelake/view/orders/common.widgets/line.item/line.item.selection.widget.dart';
import 'package:warelake/view/orders/common.widgets/line.item/selected.line.item.controller.dart';
import 'package:warelake/view/utils/alert_dialogs.dart';

class AddLineItemScreen extends ConsumerStatefulWidget {
  const AddLineItemScreen({super.key, this.lineItem = const None()});
  final Option<LineItem> lineItem;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddLineItemScreenState();
}

class _AddLineItemScreenState extends ConsumerState<AddLineItemScreen> {
  final _formKey = GlobalKey<FormState>();
  late Option<int> quantity = widget.lineItem.fold(() => const None(), (a) => Some(a.quantity));
  late Option<double> rate = widget.lineItem.fold(() => const None(), (a) => Some(a.rateInDouble));

  @override
  Widget build(BuildContext context) {
    log("the quantity ${quantity.toNullable()}");

    return Scaffold(
        appBar: AppBar(
          title: const Text("Add Line Item"),
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
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: _buildFormChildren(ref: ref),
        ),
      ),
    );
  }

  List<Widget> _buildFormChildren({required WidgetRef ref}) {
    return [
      const LineItemSelectionWidget(),
      gapH8,
      Row(
        children: [
          Expanded(
            child: TextFormField(
              initialValue: quantity.fold(() => null, (a) => a.toString()),
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
          gapW8,
          Expanded(
            child: TextFormField(
              initialValue: rate.fold(() => null, (a) => a.toString()),
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
      if (selectedItemVariationOrNone.isNone()) {
        showAlertDialog(
          context: context,
          title: "Empty",
          content: "Please select an item first.",
          defaultActionText: "OK",
        );
        return;
      }

      final itemVariation = selectedItemVariationOrNone.toIterable().first;
      log("The rate is ${rate.toIterable().first}");
      final lineItem = LineItem.create(
          itemVariation: itemVariation,
          rate: rate.toIterable().first,
          quantity: quantity.toIterable().first,
          unit: "some unit");
      ref.read(lineItemControllerProvider.notifier).add(lineItem);
      //to reset the line item after it has been added.
      ref.read(selectedItemVariationProvider.notifier).state = const None();
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
