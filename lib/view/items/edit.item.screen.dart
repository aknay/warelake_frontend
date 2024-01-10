import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inventory_frontend/domain/item/entities.dart';
import 'package:inventory_frontend/domain/item/payloads.dart';
import 'package:inventory_frontend/view/constants/app.sizes.dart';
import 'package:inventory_frontend/view/items/item.list.controller.dart';

class EditItemScreen extends ConsumerStatefulWidget {
  const EditItemScreen({super.key, required this.item});
  final Option<Item> item;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends ConsumerState<EditItemScreen> {
  final _formKey = GlobalKey<FormState>();
  Option<String> itemName = const None();
  Option<String> itemUnit = const None();

  @override
  void initState() {
    super.initState();
    widget.item.fold(() => null, (a) {
      itemName = Some(a.name);
      itemUnit = Some(a.unit);
    });
  }

  bool _validateAndSaveForm() {
    final form = _formKey.currentState!;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  _submit() async {
    if (_validateAndSaveForm()) {
      context.pop(ItemUpdatePayload(name: itemName.toNullable(), unit: itemUnit.toNullable()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(itemListControllerProvider);
    // final itemVariationList = ref.watch(itemVariationListControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Item"),
        actions: [
          IconButton(onPressed: state.isLoading ? null : _submit, icon: const Icon(Icons.check)),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            gapH8,
            TextFormField(
              initialValue: itemName.getOrElse(() => ""),
              decoration: const InputDecoration(
                labelText: 'Item Name *',
                hintText: 'Enter Item Name',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a item name';
                }
                return null;
              },
              onSaved: (value) => itemName = optionOf(value),
            ),
            gapH8,
            TextFormField(
              initialValue: itemUnit.getOrElse(() => ""),
              decoration: const InputDecoration(
                labelText: 'Unit *',
                hintText: 'Enter unit',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a unit';
                }
                return null;
              },
              onSaved: (value) => itemUnit = optionOf(value),
            ),
          ],
        ),
      ),
    );
  }
}
